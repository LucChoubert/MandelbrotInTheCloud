The Story of moving a simple implementation of a Mandelbrot exploration web app to the Cloud


The Mandelbrot Set is easy to draw and provide beautifull images. I wrote a very simple web application as a support for this article. I will use this web app to illustrate the various options, and their challenge to move an application to the cloud.

![Typical Mandelbrot Set image](./Mandelbrot.jpg)

If you want more details on the theory of the Mandelbrot Set you can check this [article](https://en.wikipedia.org/wiki/Mandelbrot_set "Mandelbrot Set in Wikipedia") in Wikipedia.


The web app is made of a simple html/Javascript frontend to get user inputs of the Mandelbrot Set area to draw. The heavy calculation is done via a REST API call to a backend, today written in Python/Flask.

The implementation is accessible via my Github repo [MandelbrotInTheCloud](https://github.com/LucChoubert/MandelbrotInTheCloud).



