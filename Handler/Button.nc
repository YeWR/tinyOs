/*button interface*/
interface Button {
  command void start();
  command void stop();
  event void startDone(error_t err);
  event void stopDone(error_t err);

  command void readA();
  command void readB();
  command void readC();
  command void readD();
  command void readE();
  command void readF();

  event void readADone(error_t err, bool val);
  event void readBDone(error_t err, bool val);
  event void readCDone(error_t err, bool val);
  event void readDDone(error_t err, bool val);
  event void readEDone(error_t err, bool val);
  event void readFDone(error_t err, bool val);
}