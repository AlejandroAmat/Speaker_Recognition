#!/bin/bash

# Scripting is very useful to repeat tasks, as testing different configuration, multiple files, etc.
# This bash script is provided as one example
# Please, adapt at your convinience, add cmds, etc.
# Antonio Bonafonte, Nov. 2015

# Establecemos que el código de retorno de un pipeline sea el del último programa con código de retorno
# distinto de cero, o cero si todos devuelven cero.
set -o pipefail

## @file
# \TODO
# Set the proper value to variables: lists, w, name_exp and db
# - lists:    directory with the list of signal files
# - w:        a working directory for temporary files
# - name_exp: name of the experiment
# - db_devel: directory of the speecon database used during development
# - db_test:  directory of the database used in the final test
lists=lists
w=work
name_exp=one
db_devel=spk_8mu/speecon
db_test=spk_8mu/sr_test
world=users 
# Ficheros de resultados del reconocimiento y verificación
LOG_CLASS=$w/class_${FEAT}_${name_exp}.log
LOG_VERIF=$w/verif_${FEAT}_${name_exp}.log
FINAL_CLASS=$w/class_test.log
FINAL_VERIF=$w/verif_test.log

# Como el fichero con el resultado de la verificación final es diferente al
# proporcionado por el programa gmm_verify, puede serle útil usar un fichero
# temporal para almacenar este resultado intermedio
TEMP_VERIF=$w/temp_${FEAT}_${name_exp}.log

# ------------------------
# Usage
# ------------------------

if [[ $# < 1 ]]; then
   echo "Empleo: $0 command..."
   echo ""
   echo "Where command can be one or more of the following (in this order):"
   echo ""
   echo "      FEAT: where FEAT is the name of a feature (eg. lp, lpcc or mfcc)."
   echo "            - A function with the name compute_FEAT() must be defined."
   echo "            - Initially, only compute_lp() exists and can be used."
   echo "            - Edit this file to add your own features."
   echo ""
   echo "     train: train GMM for speaker recognition and/or verification"
   echo "      test: test GMM in speaker recognition"
   echo "  classerr: count errors in speaker recognition"
   echo "trainworld: estimate world model for speaker verification"
   echo "    verify: test gmm in verification task"
   echo " verifyerr: count errors of verify"
   echo "finalclass: reserved for final test in the classification task"
   echo "finalverif: reserved for final test in the verification task"
   echo ""
   echo "When using $0 without the command FEAT, the feature"
   echo "name must be defined beforehand."
   echo ""
   echo "For instance, in order to train, test and evaluate speaker recognition"
   echo "using MFCC features, you can execute:"
   echo ""
   echo "      FEAT=mfcc $0 train test classerr"
   exit 1
fi

# ----------------------------
# Feature extraction functions
# ----------------------------

## @file
# \TODO
# Create your own features with the name compute_$FEAT(), where $FEAT is the name of the feature.
# - Select (or change) different features, options, etc. Make you best choice and try several options.

compute_lp() {
    db=$1
    shift
    for filename in $(sort $*); do
        mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
        EXEC="wav2lp 15 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
        echo $EXEC && $EXEC || exit 1
    done
}
compute_lpcc(){
    db=$1
    shift
    for filename in $(sort $*); do
        mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
        EXEC="wav2lpcc 15 14 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
        echo $EXEC && $EXEC || exit 1
    done
}

compute_mfcc(){
    db=$1
    shift
    for filename in $(sort $*); do
        mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
        EXEC="wav2mfcc 20 30 8 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
        echo $EXEC && $EXEC || exit 1
    done
}

#  Set the name of the feature (not needed for feature extraction itself)
if [[ ! -n "$FEAT" && $# > 0 && "$(type -t compute_$1)" = function ]]; then
    FEAT=$1
elif [[ ! -n "$FEAT" ]]; then
    echo "Variable FEAT not set. Please rerun with FEAT set to the desired feature."
    echo
    echo "For instance:"
    echo "    FEAT=mfcc $0 $*"

    exit 1
fi

# ---------------------------------
# Main program: 
# For each cmd in command line ...
# ---------------------------------

for cmd in $*; do
   echo `date`: $cmd '---';

   if [[ $cmd == train ]]; then
       ## @file
       # \TODO
       # Select (or change) good parameters for gmm_train
       for dir in $db_devel/BLOCK*/SES* ; do
           name=${dir/*\/}
           echo $name ----
           EXEC="gmm_train -v 1 -T 0.000001 -N 60 -m 64 -d $w/$FEAT -e $FEAT -g $w/gmm/$FEAT/$name.gmm $lists/class/$name.train"
           echo $EXEC && $EXEC || exit 1
           echo
       done
   elif [[ $cmd == test ]]; then
        EXEC="gmm_classify -d $w/$FEAT -e $FEAT -D $w/gmm/$FEAT -E gmm $lists/gmm.list $lists/class/all.test"
        echo $EXEC && $EXEC | tee $LOG_CLASS || exit 1

   elif [[ $cmd == classerr ]]; then
       if [[ ! -s $LOG_CLASS ]] ; then
          echo "ERROR: $LOG_CLASS does not exist"
          exit 1
       fi
       # Count errors
       perl -ne 'BEGIN {$ok=0; $err=0}
                 next unless /^.*SA(...).*SES(...).*$/; 
                 if ($1 == $2) {$ok++}
                 else {$err++}
                 END {printf "nerr=%d\tntot=%d\terror_rate=%.2f%%\n", ($err, $ok+$err, 100*$err/($ok+$err))}' $LOG_CLASS | tee -a $LOG_CLASS

   elif [[ $cmd == trainworld ]]; then
       ## @file
       # \TODO
       # Implement 'trainworld' in order to get a Universal Background Model for speaker verification
       #
       # - The name of the world model will be used by gmm_verify in the 'verify' command below.
       gmm_train -d $w/$FEAT -e $FEAT -g $w/gmm/$FEAT/$world.gmm $lists/verif/$world.train || exit 1

   elif [[ $cmd == verify ]]; then
       ## @file
       # \TODO 
       # Implement 'verify' in order to perform speaker verification
       #
       # - The standard output of gmm_verify must be redirected to file $LOG_VERIF.
       #   For instance:
       #   * <code> gmm_verify ... > $LOG_VERIF </code>
       #   * <code> gmm_verify ... | tee $LOG_VERIF </code>
       EXEC="gmm_verify -d $w/$FEAT -e $FEAT -D $w/gmm/$FEAT -E gmm -w $world $lists/gmm.list $lists/verif/all.test $lists/verif/all.test.candidates"
       echo $EXEC && $EXEC | tee $TEMP_VERIF || exit 1

   elif [[ $cmd == verifyerr ]]; then
       if [[ ! -s $TEMP_VERIF ]] ; then
          echo "ERROR: $TEMP_VERIF not created"
          exit 1
       fi
       # You can pass the threshold to spk_verif_score.pl or it computes the
       # best one for these particular results.
       spk_verif_score $TEMP_VERIF | tee -a $LOG_VERIF



   elif [[ $cmd == finalclass ]]; then
       ## @file
       # \TODO
       # Perform the final test on the speaker classification of the files in spk_ima/sr_test/spk_cls.
       # The list of users is the same as for the classification task. The list of files to be
       # recognized is lists/final/class.test
       #
       # El fichero con el resultado del reconocimiento debe llamarse $FINAL_CLASS, que deberá estar en el
       # directorio de la práctica (PAV/P4).
       
       compute_$FEAT $db_test $lists/final/class.test
       EXEC="gmm_classify -d $w/$FEAT -e $FEAT -D $w/gmm/$FEAT -E gmm $lists/gmm.list $lists/final/class.test"
       echo $EXEC && $EXEC | tee $FINAL_CLASS || exit 1

   elif [[ $cmd == finalverif ]]; then
       ## @file
       # \TODO
       # Perform the final test on the speaker verification of the files in spk_ima/sr_test/spk_ver.
       # The list of legitimate users is lists/final/verif.users, the list of files to be verified
       # is lists/final/verif.test, and the list of users claimed by the test files is
       # lists/final/verif.test.candidates
       #
       # El fichero con el resultado de la verificación debe llamarse $FINAL_VERIF, que estará en el
       # directorio de la práctica (PAV/P4).
       #
       # ATENCIÓN:
       # $FINAL_VERIF tiene un formato diferente al proporcionado por 'gmm_verify'. En la salida del
       # programa, que puede guardar en $TEMP_VERIF, la tercera columna es la puntuación dada al
       # candidato para la señal a verificar. En $FINAL_VERIF se pide que la tercera columna sea 1,
       # si se considera al candidato legítimo, o 0, si se considera impostor. Las instrucciones para
       # realizar este cambio de formato están en el enunciado de la práctica.
       compute_$FEAT $db_test $lists/final/verif.test
       EXEC="gmm_verify -d $w/$FEAT -e $FEAT -D $w/gmm/$FEAT -E gmm -w $world $lists/gmm.list $lists/final/verif.test $lists/final/verif.test.candidates"
       echo $EXEC && $EXEC | tee $TEMP_VERIF || exit 1
       perl -ane 'print "$F[0]\t$F[1]\t";
       if ($F[2] > -0.00369532958170099) {print "1\n"}
       else {print "0\n"}' $TEMP_VERIF | tee $FINAL_VERIF
   
   # If the command is not recognize, check if it is the name
   # of a feature and a compute_$FEAT function exists.
   elif [[ "$(type -t compute_$cmd)" = function ]]; then
       FEAT=$cmd
       compute_$FEAT $db_devel $lists/class/all.train $lists/class/all.test

   else
       echo "undefined command $cmd" && exit 1
   fi
done

date

exit 0
