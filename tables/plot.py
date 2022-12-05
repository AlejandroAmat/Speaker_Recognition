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
