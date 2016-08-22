import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer song;
FFT         fft;

float a4 = 440.0;
float scale = 2;
int samplingRate = 44100;
int timeDomain = 4096 * 4;
int sideLength = 800;
int bands = 360;


void setup()
{
  size(800, 800);
  frameRate(60);
  colorMode(HSB, 360, 100, 100, 120);
  
  minim = new Minim(this);
  song = minim.loadFile("track1.mp3", timeDomain);
  
  // loop the file indefinitely
  song.loop();
  
  // create an FFT object that has a time-domain buffer 
  // the same size as song's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( song.bufferSize(), song.sampleRate() );
  fft.logAverages(1, 24);
}

void draw()
{
  fill(0,0,0,60);
  rect(0,0,width, height);
  
  fft.forward( song.mix );
  drawSpectrum(fft);
}

void drawSpectrum(FFT fft){
  for(int i = 0; i < bands ; i++)
  {
    float freq = fft.getAverageCenterFrequency(i);
    float amp = fft.getBand(i);
    //println(i + ") " + freq + ": " + fft.getBand(i));
    
    float weight = sqrt(amp);
    
    if (weight > 1) {
      strokeWeight(weight);
      float theta = calcTheta(freq);
      float magnitude = sideLength / 2.0 - 10;
      float hue = degrees(theta) % 360;
      if (hue < 0) {
       hue = hue + 360; 
      }
      stroke(hue, 100, 50 + 10 * theta/TWO_PI, fft.getBand(i) / 3);
      fill(hue, 100, 50 + 10 * theta/TWO_PI, fft.getBand(i) * 6);
      drawRadial(theta, magnitude);
      drawPoint(theta, magnitude, fft.getBand(i));
    }
  }
  println();
}

void drawPoint(float theta, float magnitude, float band) {
   float x = (magnitude/2 + 40 * theta/TWO_PI) * cos(theta);
   float y = (magnitude/2 + 40 * theta/TWO_PI)  * sin(theta);
   float s = map(band, 1, 200, 1, 7);
   ellipse(sideLength/2.0 + x, sideLength/2.0 + y, s, s);
}

void drawRadial(float theta, float magnitude) {
 float x = magnitude*2 * cos(theta);
 float y = magnitude*2 * sin(theta);
 //println("drawRadial t, m, x, y  : " + theta + ", " + magnitude + ", " + x + ", " + y);
 line( sideLength/2.0,sideLength/2.0, x + sideLength/2.0, y + sideLength/2.0 );
}


// The center frequency of each band is usually expressed as
// a fraction of the sampling rate of the time domain signal and is equal to 
// the index of the frequency band divided by the total number of bands.
//
// As an example, if you construct an FFT with a timeSize of 1024 and
// a sampleRate of 44100 Hz, then the spectrum will contain values for 
// frequencies below 22010 Hz, which is the Nyquist frequency (half the sample rate). 
// If you ask for the value of band number 5, this will correspond to a frequency band 
// centered on 5/1024 * 44100 = 0.0048828125 * 44100 = 215 Hz.

float calcTheta(float freq) {
  float n; // twelth steps around the circle
  n = log(freq/a4) / log( pow(2, 1/12.0) );
  float theta = n/12.0 * TWO_PI;
  return theta;
}