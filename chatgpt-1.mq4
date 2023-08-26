// External Parameters
input double riskPercentage = 1.0;
input double maxDrawdownPercentage = 10.0;
input int tickThreshold = 5;
input int trendStrengthThreshold = 20;
input double baseLotSize = 0.1;
input ENUM_TIMEFRAMES timeframe = PERIOD_H1;
input int maxSpread = 50;

int previousTradeResult = 0; // 0 = no trades yet, 1 = win, -1 = loss
double lastBid = 0, lastAsk = 0;
datetime lastTradeTime = 0;
double LotSize;

void OnTick()
{
   // Further checks
   if (Symbol() != "EURUSD")
      return;
  
   if (TimeCurrent() - lastTradeTime < 60)
      return; 

   if (AccountMarginLevel() < 150)
   {
       Print("Margin level is too low. Risk of Stop Out.");
       return;
   }

   if (!IsTrendStrong() || !IsMACDPositive())
      return; 

   double accountBalance = AccountBalance();
   double maxDrawdown = accountBalance * (maxDrawdownPercentage / 100);

   double riskAmount = MathMin(accountBalance * (riskPercentage / 100), maxDrawdown);

   if (previousTradeResult == 0)
   {
      LotSize = baseLotSize;
   }
   else if (previousTradeResult == 1)
   {
      LotSize = LotSize * 1.5; // Increase lot size after a win
   }
   else if (previousTradeResult == -1)
   {
      LotSize = LotSize * 0.5; // decrease lot size after a loss
   }

   LotSize = MathMin(LotSize, riskAmount / (TicketSize() * 10));
   // Rest of the code remains the same...
}

bool IsTrendStrong()
{
   double adx_main = iADX(Symbol(), timeframe, 14, PRICE_CLOSE, MODE_MAIN, 1);
   bool isTrendStrong = (adx_main >= trendStrengthThreshold);
   return isTrendStrong;
}

bool IsMACDPositive()
{
   int macd_period_fast = 12, macd_period_slow = 26, macd_period_signal = 9;
   double main_MACD = iMACD(Symbol(), timeframe, macd_period_fast, macd_period_slow, 
   macd_period_signal, PRICE_CLOSE, MODE_MAIN, 1);
   bool isMACDPositive = (main_MACD >= 0);
   return isMACDPositive;
}
