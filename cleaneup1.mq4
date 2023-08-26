//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

input double volume;
double Step = 0.0002;
input int TotalTP;
int Slippage = 5;
double LastPrice;
double Equity;
double BuyCount = 0;
double SellCount = 0;
double InitialEquity;
double buyclosed;
double sellclosed;
datetime Timee;
double MaxEquity1;
double MaxEquity2;

//+------------------------------------------------------------------+
//| Close all open orders                                            |
//+------------------------------------------------------------------+
void CloseAll() {
    for(int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
  
      if(OrderType() == OP_BUY) {
        OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrAzure);
      } else if(OrderType() == OP_SELL) {
        OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrSalmon);
      }
      
      Timee = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  CloseAll();
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  CloseAll();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
  if(OrdersTotal() == 0) {
    Equity = AccountEquity();
    LastPrice = Bid;
    OrderSend(Symbol(), OP_BUY, 3*volume, Ask, Slippage, 0, 0, NULL, 1, 0, clrNONE);
    InitialEquity = AccountEquity();
    MaxEquity1 = AccountEquity();
    MaxEquity2 = AccountEquity();
    BuyCount = 3*volume;
    SellCount = 0;
    Timee = 0;
  }

  if(AccountEquity() > InitialEquity + TotalTP) {
    CloseAll();
    InitialEquity = AccountEquity();
  }

  int t1 = OrderSend(Symbol(), OP_SELL, 0.01, Bid, Slippage, 0, 0, NULL, 3, 0, clrNONE);
  OrderClose(t1, 0.01, Ask, Slippage, clrNONE);

  if(AccountEquity() > MaxEquity1) MaxEquity1 = AccountEquity();

  bool isEquityIncreased = AccountEquity() - Equity > 0;
  bool isMarginSafe = AccountMargin() < (0.75 * AccountEquity());
  bool isMaxEquitySafe = MaxEquity1 - AccountEquity() < 0.05 * MaxEquity1;

  if(isEquityIncreased && isMarginSafe && isMaxEquitySafe) {
    TradeBuy(NormalizeDouble(0.00057 * AccountEquity() * volume, 2), 1);
    Equity = AccountEquity();
  }

  if(isEquityIncreased && BuyCount <= SellCount) {
    TradeSell(20 * volume, 2);
    if(AccountMargin()< 0.95 * AccountEquity()) CloseBuyLoss1(0.0138);
    if(BuyCount > SellCount) CloseBuyProfit1(0.0018, 1);
    Equity = AccountEquity();
  }

  if(isEquityIncreased && BuyCount > SellCount) {
    TradeBuy(2 * volume, 2);
    if(AccountMargin() < 0.95 * AccountEquity()) CloseSellLoss1(0.0138);
    if(BuyCount < SellCount) CloseSellProfit1(0.0018, 1);
    Equity = AccountEquity();
  }

  if(MathAbs(Bid - LastPrice) > 0.0001) {
    LastPrice = Bid;
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeBuy(double OrderLot, int magicb) {
  OrderSend(Symbol(), OP_BUY,OrderLot, Ask, Slippage, 0,0, NULL, magicb, 0, clrNONE);
  BuyCount = BuyCount + OrderLot;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeSell(double OrderLot, int magics) {
  OrderSend(Symbol(), OP_SELL, OrderLot, Bid, Slippage, 0, 0, NULL, magics, 0, clrNONE);
  SellCount = SellCount + OrderLot;
}
