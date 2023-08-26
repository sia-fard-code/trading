// Define risk management parameters
input double riskPercentage = 1.0; // Risk per trade as a percentage of account balance
input double maxDrawdownPercentage = 10.0; // Maximum allowable drawdown as a percentage of account balance

// Define trading parameters
input int tickThreshold = 5; // Number of ticks to trigger a trade
input double trendStrengthThreshold = 0.7; // Minimum trend strength to trigger a trade
input double lotSize = 0.1; // Fixed lot size for each trade

double lastBid = 0;
double lastAsk = 0;
datetime lastTradeTime = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    if (Symbol() != "EURUSD")
        return;

    double accountBalance = AccountBalance();
    double maxDrawdown = accountBalance * (maxDrawdownPercentage / 100);

    if (TimeCurrent() - lastTradeTime < 60)
        return; // Limit the trade frequency to once per minute

    if (!IsTrendStrong())
        return; // Avoid trading in weak trends

    double riskAmount = MathMin(accountBalance * (riskPercentage / 100), maxDrawdown);
    double stopLossPrice = 0;
    double takeProfitPrice = 0;

    if (Spread() <= maxSpread)
    {
        if (lastBid == 0)
        {
            lastBid = MarketInfo(Symbol(), MODE_BID);
            lastAsk = MarketInfo(Symbol(), MODE_ASK);
            return;
        }

        if (MathAbs(lastBid - MarketInfo(Symbol(), MODE_BID)) >= SymbolPoint() * tickThreshold)
        {
            int direction = lastBid < MarketInfo(Symbol(), MODE_BID) ? OP_BUY : OP_SELL;

            if (direction == OP_BUY)
            {
                stopLossPrice = lastBid - ATR(14) * 2;
                takeProfitPrice = lastBid + ATR(14) * 4;
            }
            else if (direction == OP_SELL)
            {
                stopLossPrice = lastBid + ATR(14) * 2;
                takeProfitPrice = lastBid - ATR(14) * 4;
            }

            double tradeVolume = NormalizeDouble(riskAmount / (stopLossPrice - lastBid), 2);

            int ticket = OrderSend(Symbol(), direction, tradeVolume, MarketInfo(Symbol(), MODE_BID), 3, stopLossPrice, takeProfitPrice, "Advanced Tick-based Trade", 0, clrNONE);

            if (ticket > 0)
            {
                Print("Trade placed successfully. Ticket: ", ticket);
                lastTradeTime = TimeCurrent();
            }
            else
            {
                Print("Error placing trade. Error code: ", GetLastError());
            }
        }

        lastBid = MarketInfo(Symbol(), MODE_BID);
        lastAsk = MarketInfo(Symbol(), MODE_ASK);
    }
}

bool IsTrendStrong()
{
    double trendStrength = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
    return trendStrength >= trendStrengthThreshold;
}
