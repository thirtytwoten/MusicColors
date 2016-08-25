import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer song;
FFT         fft;

float a4 = 440.0;
int samplingRate = 44100;
int timeDomain = 4096 * 4;
float[] freqs;
int sideLength = 800;
int center = sideLength/2;


void setup()
{
  size(800, 800);
  frameRate(60);
  colorMode(HSB, 360, 100, 100, 120);
  
  calcFreqs();
  minim = new Minim(this);
  song = minim.loadFile("track1.mp3", timeDomain);
  song.loop();
  // create an FFT object that has a time-domain buffer 
  // the same size as song's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  //println("song.bufferSize(): " + song.bufferSize());
  //println("song.sampleRate(): " + song.sampleRate());
  fft = new FFT( song.bufferSize(), song.sampleRate() );
}

void draw()
{
  fill(0,0,0,60);
  rect(0,0,width, height);
  fft.forward( song.mix );
  
  int x = 1;
  int band440 = fft.freqToIndex(440.0);
  for(int i = 0; i < fft.specSize() && i % x == 0; i++)
  {
    float freq = freqs[i];
    float amp = fft.getBand(i);
    //println(freq + ": " + amp);
    if (amp > 1) {
      float theta = calcTheta(freq);
      float radius = center - 10;
      float hue = degrees(theta) % 360;
      if (hue < 0) {
       hue = hue + 360; 
      }
      stroke(hue, 100, 50 + 10 * theta/TWO_PI, amp / 3);
      fill(hue, 100, 50 + 10 * theta/TWO_PI, amp * 6);
      drawRadial(theta, radius);
      drawPoint(theta, radius, amp);
      if ( i > band440) {
          x = i / band440; 
      }
    }
  }
}

void drawPoint(float theta, float radius, float band) {
   float x = (radius/2 + 40 * theta/TWO_PI) * cos(theta);
   float y = (radius/2 + 40 * theta/TWO_PI)  * sin(theta);
   float s = map(band, 1, 200, 1, 7);
   ellipse(center + x, center + y, s, s);
}

void drawRadial(float theta, float radius) {
 float x = radius * 2 * cos(theta);
 float y = radius * 2 * sin(theta);
 //println("drawRadial t, m, x, y  : " + theta + ", " + radius + ", " + x + ", " + y);
 line(center, center, x + center, y + center);
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
//
void calcFreqs() {
 freqs = new float[timeDomain];
 for (int i = 0; i < timeDomain; i++) {
   freqs[i] = i * samplingRate / timeDomain;
   //println("freq[" + i + "]: " + freqs[i]);
 }
}

float calcTheta(float freq) {
  float n = log(freq/a4) / log( pow(2, 1/12.0) );  // amount of twelth steps around circle
  float theta = n/12.0 * TWO_PI;
  return theta;
}