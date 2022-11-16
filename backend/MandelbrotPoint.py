from PIL import Image
import time

class TimerError(Exception):
    """A custom exception used to report errors in use of Timer class"""


class Timer:
    def __init__(self):
        self._start_time = None
        self._stop_time = None


    def start(self):
        """Start a new timer"""
        if self._start_time is not None:
            raise TimerError(f"Timer is running. Use .stop() to stop it")
        self._stop_time = None
        self._start_time = time.perf_counter()


    def stop(self):
        """Stop the timer, and report the elapsed time"""
        if self._start_time is None:
            raise TimerError(f"Timer is not running. Use .start() to start it")
        self._stop_time = time.perf_counter()

    def __str__(self):
        elapsed_time = self._stop_time - self._start_time
        self._start_time = None
        self._stop_time = None
        return "Elapsed time: {elapsed_time:0.4f} seconds"

    def getElapsed_time(self):
        elapsed_time = self._stop_time - self._start_time
        self._start_time = None
        self._stop_time = None
        return elapsed_time

class MandelbrotPoint:
    INFINITY = 2
    MAX_ITER = 100

    def __init__(self,x,y):
        self.x = x
        self.y = y
    
    def __str__(self):
        return "x={0} y={1}".format(self.x, self.y)

    def colorOrbite(self, n, a, b):
        if n < self.MAX_ITER:
            i = n % 16
            mapping = {}
            mapping[0]=[66, 30, 15]
            mapping[1]=[25, 7, 26]
            mapping[2]=[9, 1, 47]
            mapping[3]=[4, 4, 73]
            mapping[4]=[0, 7, 100]
            mapping[5]=[12, 44, 138]
            mapping[6]=[24, 82, 177]
            mapping[7]=[57, 125, 209]
            mapping[8]=[134, 181, 229]
            mapping[9]=[211, 236, 248]
            mapping[10]=[241, 233, 191]
            mapping[11]=[248, 201, 95]
            mapping[12]=[255, 170, 0]
            mapping[13]=[204, 128, 0]
            mapping[14]=[153, 87, 0]
            mapping[15]=[106, 52, 3]
            return mapping[i]
        else:
            return [0, 0, 0]

    def colorOrbiteWB(self, n, a, b):
        #TODO
        if n < self.MAX_ITER:
            return [255, 255, 255]
        else:
            return [0, 0, 0]

    def getColor(self):
        a = 0
        b = 0
        i = 0
        N = 0
        a2 = a*a
        b2 = b*b
        inf = self.INFINITY * self.INFINITY
        while N < inf and i < self.MAX_ITER:
            aa = a
            a = a2-b2 + self.x
            b = 2*aa*b + self.y
            i+=1
            a2 = a*a
            b2 = b*b
            N = a2+b2
        return self.colorOrbite(i,a,b)


class MandelbrotSet:

    #x,y coordinate of center of image, width and height the number of pixels to compute
    def __init__(self,xmin,xmax,ymin,ymax,width=640, height=480):
        self._xmin = xmin
        self._xmax = xmax
        self._ymin = ymin
        self._ymax = ymax
        self._width = width
        self._height = height
        self._data = None
        self._image = None

    def compute(self):
        self._image = Image.new("RGB", (self._width, self._height), color=0)
        xstep = (self._xmax - self._xmin) / self._width
        ystep = (self._ymax - self._ymin) / self._height
        i=0
        while i<self._width:
            j=0
            while j<self._height:
                m = MandelbrotPoint(self._xmin+i*xstep, self._ymin+j*ystep)
                #m.getColor()
                self._image.putpixel( (i, j), tuple( m.getColor() ) )
                j+=1
            i+=1

    def exportToImage(self):
        return self._image

if __name__ == "__main__":
    NB_TEST = 10
    total_time = 0
    for n in range(NB_TEST):
        t = Timer()
        t.start()
        mSet = MandelbrotSet(-2,1,-1.5,1.5,1000)
        mSet.compute()
        t.stop()
        e = t.getElapsed_time()
        print("Boucle {0} ran in {1:0.4f} seconds".format(n, e))
        total_time += e
        #print(t)
        #mSet.exportToImage().show()
    print("Have run {0} Mandelbrot Set calculations in {1:0.4f} seconds average".format(NB_TEST, total_time/NB_TEST))












"""
     QColor MainWindow::computeColor(long double ix, long double iy, int in, int in_max) {

    QString selectedMode = ui->coloringComboBox->currentText();

    if (selectedMode == "Continuous") {
        long double log_zn = log( ix * ix + iy * iy ) / 2;
        //long double zn = sqrt( ix * ix + iy * iy );
        float hue = in + 1 - log( log_zn/log(2) ) / log(2);
        hue=(int)hue%360;
        QColor color;
        color.setHsv(hue,255,255);
        return color;
    }


    if (selectedMode == "Continuous 2") {
        long double log_zn = log( ix * ix + iy * iy ) / 2;
        long double nu = in + 1 - log( log_zn / log(2) );
        double fractpart, intpart;
        fractpart = modf((double)(nu*3), &intpart);

        float hue1 = ((int)(intpart))%360;
        float hue2 = ((int)(intpart+1))%360;
        float hue = hue1 + (hue2 - hue1)*fractpart;
        QColor color;
        color.setHsv(hue,255,255);
        return color;
    }

    if (selectedMode == "Continuous 3") {
        long double log_zn = log( ix * ix + iy * iy ) / 2;
        long double hue = in + 1 - log( (log_zn/log(2) )) / log(2);
        hue = 0.95 + 20.0 * hue;
        hue=(int)hue%360;
        QColor color;
        color.setHsv(hue,255,255);
        return color;
    }

    if (selectedMode == "Escape time") {
        float hue = (float)in/in_max;
        hue = (int)floor(hue*359);
        //qDebug() << in << mandelbrotSetDefinition.iter_max << hue;
        QColor color;
        color.setHsv(hue,255,255);
        return color;
    }

    if (selectedMode == "Histogram") {
        float hue = (float)in/in_max;
        hue = (int)floor(hue*359);
        //qDebug() << in << mandelbrotSetDefinition.iter_max << hue;
        QColor color;
        color.setHsv(hue,255,255);
        return color;
    }

    QColor color;
    color.setHsv(0,0,0);
    return color;

}
 """