import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer song;
FFT         fft;

float a4 = 440.0;
float scale = 2;
int samplingRate = 44100;
int timeDomain = 4096 * 4;
float[] freqs;
int sideLength = 800;


void setup()
{
  println(100%0.73);
  size(800, 800);
  frameRate(60);
  
  minim = new Minim(this);
  song = minim.loadFile("track1.mp3", timeDomain);
  
  // loop the file indefinitely
  song.loop();
  
  // create an FFT object that has a time-domain buffer 
  // the same size as song's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  println("song.bufferSize(): " + song.bufferSize());
  println("song.sampleRate(): " + song.sampleRate());
  fft = new FFT( song.bufferSize(), song.sampleRate() );
  calcFreqs();
  colorMode(HSB, 360, 100, 100, 120);
  
}

void draw()
{
  fill(0,0,0,60);
  rect(0,0,width, height);
  
  // perform a forward FFT on the samples in songs's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( song.mix );
  
  int x = 1;
  int band440 = 163;
  for(int i = 0; i < fft.specSize() && i % x == 0; i++)
  {
    println(freqs[i] + ": " + fft.getBand(i));
    if (fft.getBand(i) > 1) {
      float theta = calcTheta(i);
      float magnitude = sideLength / 2.0 - 10;
      float hue = degrees(theta) % 360;
      if (hue < 0) {
       hue = hue + 360; 
      }
      stroke(hue, 100, 50 + 10 * theta/TWO_PI, fft.getBand(i) / 3);
      fill(hue, 100, 50 + 10 * theta/TWO_PI, fft.getBand(i) * 6);
      drawRadial(theta, magnitude);
      drawPoint(theta, magnitude, fft.getBand(i));
      if ( i > band440) {
          x = i / band440; 
      }
    }
    
    //stroke(0);
    //stroke(i%32, 100, 100);
    //line( i, height, i, height - fft.getBand(i)*8 );
    //rect(i*r_width, height, r_width, -fft.getBand(i)*scale);
  }
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


void calcFreqs() {
 freqs = new float[timeDomain];
 for (int i = 0; i < timeDomain; i++) {
   freqs[i] = i * samplingRate / timeDomain;
   //println("freq[" + i + "]: " + freqs[i]);
 }
}

float calcTheta(int i) {
  float n; // twelth steps around the circle
  n = log(freqs[i]/a4) / log( pow(2, 1/12.0) );
  float theta = n/12.0 * TWO_PI;
  return theta;
}