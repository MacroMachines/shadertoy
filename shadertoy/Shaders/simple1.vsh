
attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3
attribute vec2 surfacePosAttrib;
varying vec2 surfacePosition;

void main(void) { // 4
    surfacePosition = surfacePosAttrib;
    DestinationColor = SourceColor; // 5
    gl_Position =   Position; // 6
    
}

