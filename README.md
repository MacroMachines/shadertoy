### Shadertoy - GLSL glslsandbox.com shader runner
=========

About this project:

This is a fork from openkava that I hacked on a bit in order to make it work on iPad, and also added a rudimentary gallery view
and source editor to help me learn openGL / shader language.

It tries to work like the site, loading a gallery of thumbnail images.
You can select a shader from the gallery, run it, edit it, run again.

It is a very rough cut, alpha level software but it does run (some of) the shaders that were made to run on glslsandbox.com.
Many of the shaders on the sandbox need more firepower than the ipad provides, and thus the frame rate is really slow on some.  Some will not compile, and there is is little protection against bad shader source coming in from the web, and this can cause crashes.
If the shader source is very long, it will probably run at a really slow rate or crash.

But for the most part will run a lot of different shaders, and load the source for you to edit and tweak to your heart's content.*


Here are some screenshots:

![gallery view](screen1.png)

![source view](screen2.png)

![shader running ](screen3.png)


The opengl parts incorporate code from a bunch of places, such as Ray Wanderlich opengl tutorials and Brad Larson's GPUImage.


* -- only tested with bluetooth keyboard

