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
    if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      continue;

    if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
      OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY) ? Bid : Ask, Slippage);
    }

    Timee = TimeCurrent();
  }
}

void TradeSell(double orderLot, int magics) {
  OrderSend(Symbol(), OP_SELL, orderLot, Bid, Slippage, 0, 0, NULL, magics);
  SellCount += orderLot;
  Timee = OrderOpenTime();
}

void TradeBuy(double orderLot, int magicb) {
  OrderSend(Symbol(), OP_BUY, orderLot, Ask, Slippage, 0, 0, NULL, magicb);
  BuyCount += orderLot;
  Timee = OrderOpenTime();
}

void ActionBuy(double buyLimitUp, double max) {
  if(BuyCount <= buyLimitUp)
    return;

  for(double j = max; j >= 0; j -= 0.0001) {
    CloseBuyProfit(j);
    CloseBuyLoss(j);
  }
}

void ActionSell(double sellLimitUp, double max) {
  if(SellCount <= sellLimitUp)
    return;

  for(double j= max; j >= 0; j -= 0.0001) {
    CloseSellProfit(j);
    CloseSellLoss(j);
  }
}

void CloseBuySellProfitLoss(int ordersType, double limit, COLOR color) {
  for(int i = OrdersTotal() - 1; i >= 0; i--) {
    if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      continue;

    if(OrderType() != ordersType) 
      continue;
    
    double orderOpenPrice = OrderOpenPrice(); 
    double marketAsk = MarketInfo(Symbol(), MODE_ASK);
    bool isProfitOrLoss = (orderOpenPrice - marketAsk >= limit) ? true : false;
    if(isProfitOrLoss) {
      OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY) ? Bid : Ask, Slippage, color);
      if(OrderType() == OP_BUY){
          BuyCount -= OrderLots();
      } else if(OrderType() == OP_SELL){
          SellCount -= OrderLots();
      }
    }
  }
}

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

  if(AccountEquity() > MaxEquity1) {
    MaxEquity1 = AccountEquity();
  }

  bool isEquityIncreased = AccountEquity() - Equity > 0;
  bool isMarginSafe = AccountMargin() < (0.75 * AccountEquity());
  bool isMaxEquitySafe = MaxEquity1 - AccountEquity() < 0.05 * MaxEquity1;

  if(isEquityIncreased && isMarginSafe && isMaxEquitySafe) {
    TradeBuy(NormalizeDouble(0.00057 * AccountEquity() * volume, 2), 1);
    Equity = AccountEquity();
  }

  if(AccountEquity() - Equity < 0) {
    if(BuyCount <= SellCount) {
      TradeSell(20 * volume, 2);
      if(AccountMargin() < 0.95 * AccountEquity()) {
        CloseBuySellProfitLoss(OP_BUY, 0.0138, clrNONE);
      }
      if(BuyCount > SellCount) {
        CloseBuySellProfitLoss(OP_BUY, 0.0018, clrNONE);
      }
      Equity = AccountEquity();
    }

    if(BuyCount > SellCount) {
      TradeBuy(2 * volume, 2);
      if(AccountMargin() < 0.95 * AccountEquity()) {
        CloseBuySellProfitLoss(OP_SELL, 0.0138, clrNONE);
      }
      if(BuyCount < SellCount) {
        CloseBuySellProfitLoss(OP_SELL, 0.0018, clrNONE);
      }
      Equity = AccountEquity();
    }
  }

  if(MathAbs(Bid - LastPrice) > 0.0001) {
    LastPrice = Bid;
  }
// Check if bid price has been updated
  if (MathAbs(Bid - LastPrice) > 0.0001) {
    // Trade Buy with certain conditions
    if (BuyCount > SellCount && AccountMargin() < 0.95 * AccountEquity() && AccountEquity() - MaxEquity1 < 0.05 * MaxEquity1) {
      TradeSell(NormalizeDouble(0.00057 * AccountEquity() * volume, 2), 1);
      CloseBuySellProfitLoss(OP_BUY, 0.0012, clrNONE);
      Equity = AccountEquity();
    }
      
    // Trade Sell with certain conditions 
    if (BuyCount <= SellCount && AccountMargin() < 0.95 * AccountEquity() && AccountEquity() - MaxEquity1 < 0.05 * MaxEquity1) {
      TradeBuy(NormalizeDouble(0.00057 * AccountEquity() * volume, 2), 1);
      CloseBuySellProfitLoss(OP_SELL, 0.0012, clrNONE);
      Equity = AccountEquity();
    }
  }
}
