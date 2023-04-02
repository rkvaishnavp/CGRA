from random import randint
f = open("jtag.bin", "w")
for i in range(4096):
    f.write(str(randint(0, 1)))
    f.write("\n")
