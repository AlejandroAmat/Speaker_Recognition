PAV - P4: reconocimiento y verificación del locutor
===================================================

Obtenga su copia del repositorio de la práctica accediendo a [Práctica 4](https://github.com/albino-pav/P4)
y pulsando sobre el botón `Fork` situado en la esquina superior derecha. A continuación, siga las
instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para crear una rama con el apellido de
los integrantes del grupo de prácticas, dar de alta al resto de integrantes como colaboradores del proyecto
y crear la copias locales del repositorio.

También debe descomprimir, en el directorio `PAV/P4`, el fichero [db_8mu.tgz](https://atenea.upc.edu/mod/resource/view.php?id=3654387?forcedownload=1)
con la base de datos oral que se utilizará en la parte experimental de la práctica.

Como entrega deberá realizar un *pull request* con el contenido de su copia del repositorio. Recuerde
que los ficheros entregados deberán estar en condiciones de ser ejecutados con sólo ejecutar:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  make release
  run_spkid mfcc train test classerr verify verifyerr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recuerde que, además de los trabajos indicados en esta parte básica, también deberá realizar un proyecto
de ampliación, del cual deberá subir una memoria explicativa a Atenea y los ficheros correspondientes al
repositorio de la práctica.

A modo de memoria de la parte básica, complete, en este mismo documento y usando el formato *markdown*, los
ejercicios indicados.

## Ejercicios.

### SPTK, Sox y los scripts de extracción de características.

- Analice el script `wav2lp.sh` y explique la misión de los distintos comandos involucrados en el *pipeline*
  principal (`sox`, `$X2X`, `$FRAME`, `$WINDOW` y `$LPC`). Explique el significado de cada una de las 
  opciones empleadas y de sus valores.

  * sox: Permite convertir una señal de audio en formato WAVE a una señal  sin cabeceras codificado como (-e) signed de (-b) 16 bits
    *   -t : Tipo de fichero de salida
    *   -e : Codificación a aplicar
    *   -b : Nº Bits
    *   -- : Redirigir Output 

  * $X2X -> sptk x2x : Programa de SPTK que nos permite convertir datos de una entrada estándard a otro tipo de datos (+sf, short format en nuestro caso), enviando el resultado a una salida estándar. 

  * Frame -> sptk frame: Programa de SPTK que permite convertir la señal a tramas de "l" muestras con desplazamientos de "p" muestras.En este caso la longitud es de 240 muestras y el periodo es de 80 muestras.

  * Window -> sptk window:  Multiplica cada trama por la ventana escogida. Por defecto, la de Blackman. Existen 6 tipos más. La secuencia de entrada tiene una longitud -l y la salida una nueva longitud -L. Ambos con valores máximos de 256.Se define  una longitud de 240 muestras tanto para los datos de entrada como los de salida.

  * LPC -> sptk lpc: Calcula los coeficientes LPC (predicción lineal) usando el método Levinson-Durbin. Se pueden fijar parámetros como la longitud del frame a 240 muestras y el orden del LPC. 

- Explique el procedimiento seguido para obtener un fichero de formato *fmatrix* a partir de los ficheros de
  salida de SPTK (líneas 45 a 51 del script `wav2lp.sh`).

    Entre las líneas 45 y 47 se calculan el número de filas y de columnas. Para las columnas, es relativamente sencillo pues solo debemos tener en cuenta el orden del LPC. Estas serán el orden + 1, ya que debemos tener en cuenta que se calcula la ganancia (la potencia del error). Para las filas, es más complicado, pues dependerá de los parámetros pasados en la llamada de las funciones en el pipeline. Para ello, extraemos la información del fichero base.lp (que contiene los coeficientes) y mediante sox realizamos la conversión a ASCII (fa) y se cuentan las líneas mediante wc -l.

  * ¿Por qué es más conveniente el formato *fmatrix* que el SPTK?

    Es más conveniente el formato fmatrix dado que se puede acceder a los coeficientes de cada trama de una forma más sencillla y rápida. Esto es, ya que en formato matricial tenemos que los índices i,j de la matriz corresponden con el coeficiente i de la trama j.

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales de predicción lineal
  (LPCC) en su fichero <code>scripts/wav2lpcc.sh</code>:

      sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	  $LPC -l 240 -m $lpc_order | $LPCC -m $lpc_order -M $lpcc_order > $base.lpcc ||exit 1
   

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales en escala Mel (MFCC) en su
  fichero <code>scripts/wav2mfcc.sh</code>:

      sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
      $MFCC -l 240 -m $mfcc_order -n $filter_order -s $fq > $base.mfcc

### Extracción de características.

- Inserte una imagen mostrando la dependencia entre los coeficientes 2 y 3 de las tres parametrizaciones
  para todas las señales de un locutor.
  
  * LPC

    ![Alt text](./img/lp.png?raw=true "Optional Title")

  * LPCC 

    ![Alt text](./img/lpcc.png?raw=true "Optional Title")

  * MFCC

    ![Alt text](./img/mfcc.png?raw=true "Optional Title")

    * Código:

    ```c
    import matplotlib.pyplot as plt

    # LP
    X, Y = [], []
    for line in open('./tables/lp.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(1)
    plt.plot(X, Y, 'bd', markersize=1.5)
    plt.title('Linear Prediction Coefficients',fontsize=15)
    plt.grid()
    plt.xlabel('a(2)')
    plt.ylabel('a(3)')
    plt.show()


    # LPCC
    X, Y = [], []
    for line in open('./tables/lpcc.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(1)
    plt.plot(X, Y, 'gd', markersize=1.5)
    plt.title('Linear Prediction Cepstrum Coefficients',fontsize=15)
    plt.grid()
    plt.xlabel('a(2)')
    plt.ylabel('a(3)')
    plt.show()

    # MFCC
    X, Y = [], []
    for line in open('./tables/mfcc.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(1)
    plt.plot(X, Y, 'rd', markersize=1.5)
    plt.title('Mel Frequency Cepstrum Coefficients',fontsize=15)
    plt.grid()
    plt.xlabel('a(2)')
    plt.ylabel('a(3)')
    plt.show()

    ```

  + Indique **todas** las órdenes necesarias para obtener las gráficas a partir de las señales 
    parametrizadas.


    * 1: Obtención ficheros .FEAT y directorio work:

      * (i) run_spkid :

        ```c
        compute_lp() {
            db=$1
            shift
            for filename in $(sort $*); do
                mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
                EXEC="wav2lp 8 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
                echo $EXEC && $EXEC || exit 1
            done
        }
        compute_lpcc(){
            db=$1
            shift
            for filename in $(sort $*); do
                mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
                EXEC="wav2lpcc 8 12 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
                echo $EXEC && $EXEC || exit 1
            done
        }

        compute_mfcc(){
            db=$1
            shift
            for filename in $(sort $*); do
                mkdir -p `dirname $w/$FEAT/$filename.$FEAT`
                EXEC="wav2mfcc 15 24 8 $db/$filename.wav $w/$FEAT/$filename.$FEAT"
                echo $EXEC && $EXEC || exit 1
            done
        }
        ```
      * (ii) run del script para las 3 parametrizaciones:
            
            run_spkid mfcc
            run_spkid lpcc
            run_spkid lp
             
    * (2) Archivos txt de coeficientes 2,3:

          fmatrix_show work/lp/BLOCK01/SES013/*.lp | egrep '^\[' | cut -f4,5 > ./tables/lp.txt

          fmatrix_show work/lpcc/BLOCK01/SES013/*.lpcc | egrep '^\[' | cut -f4,5 > ./tables/lpcc.txt

          fmatrix_show work/mfcc/BLOCK01/SES013/*.mfcc | egrep '^\[' | cut -f4,5 > ./tables/mfcc.txt

    * (3) Gráficas

          bin/python3 /home/alejandro/Desktop/CFIS/4A/PAV/P4/P4/tables/plot.py

  + ¿Cuál de ellas le parece que contiene más información?

    Si se observa detenidamente, se puede apreciar como tanto en el LPCC como en MFCC los coeficientes están mucho más dispersos. Se distribuyen por el espacio con una relación mucho menos aparente que en el caso de LPC. Dadas estas características, se puede entender que los coeficientes del LPC presentan una correlación más elevada (Dado que prácticamente forman una recta) por lo que la entropía es mucho menor. Es así como concluímos que el LPC es el que aporta menor información. 
    En cuanto a la comparativa de MFCC vs LPCC, se observa como los coeficientes de MFCC tienen un rango mucho mayor (de 20/25) mientras que los valores del LPC se compactan entre -1 y 1. Es por eso que se entiende que los coeficientes del MFCC son los que presentan menor correlación y, por ende, mayor entropía.

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los
  parámetros 2 y 3 para un locutor, y rellene la tabla siguiente con los valores obtenidos.

  |                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | &rho;<sub>x</sub>[2,3] | -0.812152 | 0.257603 | -0.181939 |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
    Como se ha comentado y teorizado previamente, los coeficientes con mayor correlación serían los de LP, seguidos de LPCC y MFCC. Tras observar los valores normalizados mediante pearson, se confirma. El valor del coeficiente de correlación normalizada para el lp en valor absoluto es el más grande de todos, llegando prácticamente a 1. En los otros dos casos, aún teniendo valores muy similares, se comprueba que la correlaciíon es menor para MFCC.

- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

    * Para LPCC se debe considerar un valor que aproximadamente sea 3/2 de P (orden del predictor lineal). EN nuestro caso, al tener P=8, Q=12. Aunque podemos probar con valores cercanos como 13 o 14.

    * En el caso de MFCC, se debe tener en cuenta que normalmente se usan los 13 primeros coeficientes. Por lo que se ubica el umbral entre 13 y 18. Es por eso, que hemos escogido 16. Para el banco de filtros, se puede escoger entre 24 y 40 (Aún teniendo valores como 20 que pueden funcionar bien). La f es 8kHz.

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.

      plot_gmm_feat  --percents 99,80,50  work/gmm/mfcc/SES029.gmm

    ![Alt text](./img/99.png?raw=true "Optional Title")

- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.

  

### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.

|                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | error rate | 11.08% | 1.40% | 0.76% |




### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
  
  Sistema MFCC con user:

  | Th Opt | FalseAlarm | Missed | CostDetection |
  |:----:|:----:|:----:|:----:|
  | -0.00369532958170099 | 3/1000=0.0030 | 13/250=0.0520 | 7.9 |



  Sistema LPCC con user:

  | Th Opt | FalseAlarm | Missed | CostDetection |
  |:----:|:----:|:----:|:----:|
  | -0.117107543563996 | 9/1000=0.0090 | 21/250=0.0840 | 16.5 |

 
### Test final

- Adjunte, en el repositorio de la práctica, los ficheros `class_test.log` y `verif_test.log` 
  correspondientes a la evaluación *ciega* final.

### Trabajo de ampliación.

- Recuerde enviar a Atenea un fichero en formato zip o tgz con la memoria (en formato PDF) con el trabajo 
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como 
  resultado del mismo.
