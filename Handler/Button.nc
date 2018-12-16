/*button interface*/
interface Button {
  command void start();
  command void stop();
  event void startDone(error_t error);
  event void stopDone(error_t error);

  command void pinvalueA();
  command void pinvalueB();
  command void pinvalueC();
  command void pinvalueD();
  command void pinvalueE();
  command void pinvalueF();

  event void pinvalueADone(error_t error, bool isPressed);
  event void pinvalueBDone(error_t error, bool isPressed);
  event void pinvalueCDone(error_t error, bool isPressed);
  event void pinvalueDDone(error_t error, bool isPressed);
  event void pinvalueEDone(error_t error, bool isPressed);
  event void pinvalueFDone(error_t error, bool isPressed);
}