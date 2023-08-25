input double volume;
double Step=0.0002;

input int TotalTP;
int Slippage = 5;

double MaxEquity;
double Equity;
double OrderNumber=0;

double SellCount=0;
double BuyCount=0;

double InitialEquity;

datetime Timee;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         OrderClose(OrderTicket(),OrderLots(),OrderType() == OP_BUY ? Bid : Ask,Slippage,clrNONE);

      Timee=TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate()
  {
   SellCount = 0;
   BuyCount = 0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS, MODE_TRADES);

      if(OrderType()==OP_BUY)
         BuyCount += OrderLots();

      if(OrderType()==OP_SELL)
         SellCount += OrderLots();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitLoss(double threshold, int magic)
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY && MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= threshold && OrderMagicNumber() == magic)
      {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount -= OrderLots();
      }
      
      if(OrderType() == OP_SELL && OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= threshold && OrderMagicNumber() == magic)
      {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount -= OrderLots();
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseLoss(double threshold)
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY && OrderOpenPrice() > MarketInfo(Symbol(),MODE_ASK) + threshold)
      {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
      }
      
      if(OrderType() == OP_SELL && MarketInfo(Symbol(),MODE_ASK) > OrderOpenPrice() + threshold)
      {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAll()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYLIMIT)
      {
         OrderDelete(OrderTicket());
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeSell(double OrderLot,int magics)
{
   OrderSend(Symbol(), OP_SELL, OrderLot, Bid, Slippage,0,0, NULL, magics, 0, clrNONE);
   SellCount += OrderLot;
   OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_TRADES);
   Timee=OrderOpenTime();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeBuy(double OrderLot,int magicb)
{
   OrderSend(Symbol(), OP_BUY,OrderLot, Ask, Slippage, 0,0, NULL, magicb, 0, clrNONE);
   BuyCount += OrderLot;
   OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_TRADES);
   Timee=OrderOpenTime();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Reset()
{

}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   CloseAll();
   DeleteAll();
   Reset();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CloseAll();
   DeleteAll();
   Reset();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   if(OrdersTotal() == 0)
   {
      Equity = AccountEquity();
      OrderSend(Symbol(), OP_BUY,3*volume, Ask, Slippage,0,0,NULL, 1, 0, clrNONE);
      InitialEquity = AccountEquity();
      BuyCount = 3*volume;
      SellCount = 0;
      Timee = 0;
      OrderNumber = 2;
   }

   if(AccountEquity() > InitialEquity + TotalTP)
   {
      CloseAll();
      InitialEquity = AccountEquity();
   }

   Calculate();

   // Add your trading logic here
   
   // Example usage of CloseProfitLoss and CloseLoss functions
   if(BuyCount > SellCount)
   {
      CloseProfitLoss(0.0001, 1);
      CloseLoss(0.0002);
   }
   
   if(BuyCount <= SellCount)
   {
      CloseProfitLoss(0.0001, 2);
      CloseLoss(0.0002);
   }
}
