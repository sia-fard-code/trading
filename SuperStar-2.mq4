//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


input double volume;
double Step=0.0002;

input int TotalTP;
int Slippage = 5;
double StartPrice,LastPrice;
int i;
double j;
double MaxEquity;
double MaxEquity1;
double MaxEquity2;
double Equity;
int OrderNumber=0;
int x=0;

double SellCount=0;
double SellCountLoss=0;
double BuyCountLoss=0;
double SellCountProfit=0;
double BuyCountProfit=0;
double BuyCount=0;
double eq;

double          buyloss=0;
double          sellloss=0;
double          buyprofit=0;
double          sellprofit=0;

double InitialEquity;

double buyclosed;
double sellclosed;
double buyclosed2;
double sellclosed2;
double r;

datetime Timee;

int t1=0;
int t2=0;
int t3=0;
int t4=0;
int t5=0;
int t6=0;
int t7=0;
int t8=0;

int t31;
int t32;
double OBuyCount;
double OSellCount;
double Dif;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType()==OP_BUY)

         OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrAzure);

      if(OrderType()==OP_SELL)

         OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrSalmon);
      Timee=TimeCurrent();
     }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate()
  {


   BuyCountLoss = 0;
   SellCountLoss = 0;

   for(i= OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderOpenPrice() > MarketInfo(Symbol(),MODE_ASK))
        {
         BuyCountLoss = BuyCountLoss + OrderLots();
        }
      if(OrderType()==OP_SELL && MarketInfo(Symbol(),MODE_ASK) > OrderOpenPrice())
        {
         SellCountLoss = SellCountLoss + OrderLots();
        }
     }


   BuyCountProfit = 0;
   SellCountProfit = 0;

   for(i= OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && MarketInfo(Symbol(),MODE_ASK) > OrderOpenPrice())
        {
         BuyCountProfit = BuyCountProfit + OrderLots();
        }
      if(OrderType()==OP_SELL && OrderOpenPrice() > MarketInfo(Symbol(),MODE_ASK))
        {
         SellCountProfit = SellCountProfit + OrderLots();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyProfit2(double q)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= q && MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() < q+0.0001)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellProfit2(double w)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= w && OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) < w+0.0001)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyLoss2(double SLB)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= SLB)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellLoss2(double SLS)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= SLS)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyProfit1(double q, int magicbp)
  {//buyclosed=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= q && MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() < q+0.0001 && OrderMagicNumber()==magicbp)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
         buyclosed+=OrderProfit();
         TradeSell(OrderLots(),1);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellProfit1(double w, int magicsp)
  {//sellclosed=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= w && OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) < w+0.0001 && OrderMagicNumber()==magicsp)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
         sellclosed+=OrderProfit();
         TradeBuy(OrderLots(),1);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyLoss1(double n)
  {//buyclosed2=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&// -buyclosed2<MathMax(0.5*sellclosed,0) &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= n && OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) < n+0.0001)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
         buyclosed2+=OrderProfit();
         TradeSell(OrderLots(),1);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellLoss1(double m)
  {//sellclosed2=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&// -sellclosed2<MathMax(0.5*buyclosed,0) &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= m && MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() < m+0.0001)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
         sellclosed2+=OrderProfit();
         TradeBuy(OrderLots(),1);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseLoss(double CL)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         OrderOpenPrice() > MarketInfo(Symbol(),MODE_ASK)+CL)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
        }
      if(OrderType() == OP_SELL &&
         MarketInfo(Symbol(),MODE_ASK) > OrderOpenPrice()+CL)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseLoss1()
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= 6*Step)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
        }
      if(OrderType() == OP_SELL &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= 6*Step)
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
   for(i=OrdersTotal()-1; i>=0; i--)
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
void CloseBuyLoss(double a)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= a)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellLoss(double b)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= b)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyProfit(double c)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= c)
        {
         t7=OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
         OrderSelect(t7,SELECT_BY_TICKET,MODE_TRADES);
         Timee=TimeCurrent();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellProfit(double d)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= d)
        {
         t6=OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
         OrderSelect(t6,SELECT_BY_TICKET,MODE_TRADES);
         Timee=TimeCurrent();
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyLoss3(double a)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= a && BuyCount<=SellCount)
        {
         t5=OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
         OrderSelect(t5,SELECT_BY_TICKET,MODE_TRADES);
         Timee=TimeCurrent();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellLoss3(double b)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= b && BuyCount>=SellCount)
        {
         t4=OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
         OrderSelect(t4,SELECT_BY_TICKET,MODE_TRADES);
         Timee=TimeCurrent();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyProfit3(double c)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_BUY &&
         MarketInfo(Symbol(),MODE_ASK) - OrderOpenPrice() >= c && BuyCount<=SellCount)
        {
         OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrNONE);
         BuyCount=BuyCount-OrderLots();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellProfit3(double d)
  {
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderType() == OP_SELL &&
         OrderOpenPrice() - MarketInfo(Symbol(),MODE_ASK) >= d && BuyCount>=SellCount)
        {
         OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrNONE);
         SellCount=SellCount-OrderLots();
        }
     }
  }

//=============================================================================


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeSell(double OrderLot,int magics)
  {

   OrderSend(Symbol(), OP_SELL, OrderLot, Bid, Slippage,0,0, NULL, magics, 0, clrNONE);
   SellCount=SellCount+OrderLot;
   OrderSelect(t1,SELECT_BY_TICKET,MODE_TRADES);
   Timee=OrderOpenTime();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeBuy(double OrderLot,int magicb)
  {

   OrderSend(Symbol(), OP_BUY,OrderLot, Ask, Slippage, 0,0, NULL, magicb, 0, clrNONE);
   BuyCount=BuyCount+OrderLot;
   OrderSelect(t2,SELECT_BY_TICKET,MODE_TRADES);
   Timee=OrderOpenTime();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionBuy(double BuyLimitUp, double Max)
  {
   for(j=Max; j>=0; j=j-0.0001)
     {
      if(BuyCount > BuyLimitUp)
        {
         CloseBuyProfit(j);
         CloseBuyLoss(j);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionSell(double SellLimitUp, double Max)
  {

   for(j=Max; j>=0; j=j-0.0001)
     {
      if(SellCount > SellLimitUp)
        {
         CloseSellProfit(j);
         CloseSellLoss(j);
        }
     }

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
//---
   CloseAll();
   DeleteAll();
   Reset();
//---
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(OrdersTotal() == 0)
     {
      Equity = AccountEquity();
      LastPrice = Bid;
      OrderSend(Symbol(), OP_BUY,3*volume, Ask, Slippage,0,0,NULL, 1, 0, clrNONE);
      //    OrderSend(Symbol(), OP_SELL,7*volume, Bid, Slippage,0,0,NULL, 1, 0, clrNONE);
      InitialEquity = AccountEquity();
      MaxEquity1 = AccountEquity();
      MaxEquity2 = AccountEquity();

      BuyCount=3*volume;
      SellCount=0;
      Timee=0;
      OrderNumber = 2;
     }

//-------------------------------------------------------------------------------------------------------------

   /*
      if(OrdersTotal() == 2 &&
         MarketInfo(Symbol(),MODE_ASK) - StartPrice >= Step)
        {
         t3=OrderSend(Symbol(), OP_BUY,0.13, Ask, Slippage,0,0,NULL, 1, 0, clrNONE);
         //    OrderSend(Symbol(), OP_SELL,volume, Bid, Slippage,0,0, NULL, 1, 0, clrNONE);
         BuyCount=0.13;
         OrderNumber=2;
        }

   //------------------------------------------------------------

      if(OrdersTotal() == 2 &&
         StartPrice - MarketInfo(Symbol(),MODE_ASK) >= Step)
        {
         //    OrderSend(Symbol(), OP_BUY,volume, Ask, Slippage,0,0,NULL, 1, 0, clrNONE);
         t3=OrderSend(Symbol(), OP_SELL,0.13, Bid, Slippage,0,0, NULL, 1, 0, clrNONE);
         SellCount=0.13;
         OrderNumber=2;
        }
   */
//------------------------------------------------------------------------------------------------------------------

//  if(OrderNumber >= 2)
     {

      /*
            //    CloseBuyLoss(0.0005);
            //    if(BuyCount>SellCount)
              {
                        CloseBuyProfit(0.0066);
              }
            //     CloseSellLoss(0.0005);

            //    if(SellCount>BuyCount)
              {
                        CloseSellProfit(0.0066);
              }


            mbuy=1;
            msell=1;

            if(AccountEquity() > MaxEquity1)
              {
               MaxEquity1 = AccountEquity();
              }

            if(MaxEquity1 - AccountEquity() > 0.1*MaxEquity1)// && BuyCount>SellCount)
              {
               //     mbuy=MathCeil((MaxEquity1 - AccountEquity()) / (Dif));
               msell=MathCeil((MaxEquity1 - AccountEquity()) / (0.03*MaxEquity1));
               mbuy=MathCeil((MaxEquity1 - AccountEquity()) / (0.03*MaxEquity1));
              }

            if(MaxEquity1 - AccountEquity() > 0.1*MaxEquity1 && BuyCount<SellCount)
              {
               //      mbuy=MathCeil((MaxEquity1 - AccountEquity()) / (0.1*MaxEquity1));
               //    msell=MathCeil((MaxEquity1 - AccountEquity()) / (Dif));

              }
            //------------------------------------------------------------------------------------------

            if(MaxEquity1 - AccountEquity() < 0.1*MaxEquity1 && BuyCount>SellCount)
              {

               msell=MathMax(MathCeil((0.1*MaxEquity1) / MathMax((MaxEquity1 - AccountEquity()),0.01*MaxEquity1)),1);
               //CloseBuyProfit(MathMax(0.0066/msell,0.0017));
              }

            if(MaxEquity1 - AccountEquity() < 0.1*MaxEquity1 && BuyCount<SellCount)
              {
               mbuy=MathMax(MathCeil((0.1*MaxEquity1) / MathMax((MaxEquity1 - AccountEquity()),0.01*MaxEquity1)),1);

               //CloseSellProfit(MathMax(0.0066/mbuy,0.0017));
              }


            buyloss=0;
            sellloss=0;
            buyprofit=0;
            sellprofit=0;

            Calculate();

            if(BuyCountLoss<mbuy*MaxLotLoss && BuyCountLoss>0)
              {
               buyloss = NormalizeDouble(LossLot*BuyCountLoss,2);
              }


            if(SellCountLoss<msell*MaxLotLoss && SellCountLoss>0)
              {
               sellloss = NormalizeDouble(LossLot*SellCountLoss,2);
              }


            if(BuyCountProfit <mbuy*MaxLotProfit && BuyCountProfit > 0)
              {
               buyprofit = NormalizeDouble(ProfitLot*BuyCountProfit,2);
              }


            if(SellCountProfit <msell*MaxLotProfit && SellCountProfit > 0)
              {
               sellprofit = NormalizeDouble(ProfitLot*SellCountProfit,2);
              }






                  if(buyprofit>0 && SellCount>=BuyCount)// && MaxEquity2-AccountEquity()<20000)
                    {
                     //       TradeBuy(0.3*(sellprofit));
                     TradeSell(0.3*(buyprofit));
                     //       MaxEquity2=AccountEquity();
                    }

                  if(sellloss+sellprofit>0 && SellCount>=BuyCount)// && MaxEquity2-AccountEquity()>20000)
                    {
                     TradeBuy(1*(sellloss+sellprofit));
                     TradeSell(1*(buyloss+buyprofit));
                     //      MaxEquity2=AccountEquity();
                    }

                  if(buyloss+buyprofit>0 && BuyCount>SellCount)// && MaxEquity2-AccountEquity()>20000)
                    {
                     TradeSell(1*(buyloss+buyprofit));
                     TradeBuy(1*(sellloss+sellprofit));
                     //      MaxEquity2=AccountEquity();
                    }

                  if(sellprofit>0 && BuyCount>SellCount)// && MaxEquity2-AccountEquity()<20000)
                    {
                     //       TradeSell(0.3*(buyprofit));
                     TradeBuy(0.3*(sellprofit));
                     //      MaxEquity2=AccountEquity();
                    }

            */
      //Print(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));

      if(AccountEquity() > InitialEquity + TotalTP)
        {
         CloseAll();
         InitialEquity = AccountEquity();
        }





      t1=OrderSend(Symbol(), OP_SELL,0.01, Bid, Slippage,0,0, NULL, 3, 0, clrNONE);
      OrderClose(t1, 0.01, Ask, Slippage, clrNONE);



      /*
      if(AccountEquity() > 1.5*Equity && BuyCount>SellCount)
      {
               for(r=0; r<0.0188; r=r+0.0001)
                 {
                  if(BuyCount>1.2*SellCount)
                    {
                     CloseBuyProfit1(r);
                    }
                 }
      Equity = AccountEquity();
      }

      if(AccountEquity() > 1.5*Equity && BuyCount<SellCount)
      {
               for(r=0; r<0.0188; r=r+0.0001)
                 {
                  if(SellCount>1.2*BuyCount)
                    {
                     CloseSellProfit1(r);
                    }
                 }
      Equity = AccountEquity();
      }
      */           //=========================================================================================================

      /*

            if(AccountMargin() > 0.9*AccountEquity() && BuyCount>1*SellCount)
              {
               for(r=0.0010; r<0.0188; r=r+0.0001)
                 {
                  if(AccountMargin() > 0.8*AccountEquity() && BuyCount>1*SellCount)
                    {
                     CloseBuyProfit2(r);//CloseSellLoss1(0.0188-r);
                     //             TradeBuy(volume);
                    }
                 }
               for(r=0.0188; r>=0; r=r-0.0001)
                 {
                  if(AccountMargin() > 0.99*AccountEquity() && BuyCount>1*SellCount)
                    {
                     CloseAll();
                     //          CloseBuyLoss1(r);//CloseSellProfit1(0.0188-r);
                     //      TradeSell(volume,1);
                    }
                 }



              }

            //=======================================================================================================================================================


            if(AccountMargin() > 0.9*AccountEquity() && 1*BuyCount<SellCount)
              {
               for(r=0.0010; r<0.0188; r=r+0.0001)
                 {
                  if(AccountMargin() > 0.8*AccountEquity() && 1*BuyCount<SellCount)
                    {
                     CloseSellProfit2(r);//CloseBuyLoss1(0.0188-r);
                     //               TradeSell(volume);
                    }
                 }
               for(r=0.0188; r>=0; r=r-0.0001)
                 {
                  if(AccountMargin() > 0.99*AccountEquity() && 1*BuyCount<SellCount)
                    {
                     CloseAll();
                     //         CloseSellLoss1(r);//CloseBuyProfit1(0.0188-r);
                     //         TradeBuy(volume,1);
                    }
                 }



              }

            */

      if(AccountEquity() > MaxEquity1)
        {
         MaxEquity1 = AccountEquity();
        }



      //===================================================================================================================================================================
      /**/
//      if(BuyCount>SellCount)
//        {
//         OBuyCount=BuyCount;
//         Dif=BuyCount-SellCount;
//
//         // for(r=0.0011; r<=0.0188; r=r+0.0001)
//         //   {
//         //    if(BuyCount>OBuyCount-0.1*Dif && BuyCount>SellCount)//((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//         //      {
//         ////               CloseBuyLoss1(r);
//         //      }
//         //   }
//         buyclosed=0;
//         for(r=0.0018; r>=0.0004; r=r-0.0001)
//           {
//    //        if(BuyCount>SellCount)// && BuyCount>SellCount-4*((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//              {
//               CloseBuyProfit1(r,1);
//              }
//           }
//         for(r=0.0018; r>=0.0001; r=r-0.0001)
//           {
//    //        if(BuyCount>SellCount)// && BuyCount>SellCount-4*((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//              {
//               CloseBuyProfit1(r,2);
//              }
//           }
//
//        }
      /**/

      //      MaxEquity1 = AccountEquity();


      //============================================================================================================================================================

//      if(BuyCount<SellCount)
//        {
//         OSellCount=SellCount;
//         Dif=SellCount-BuyCount;
//
//         //  for(r=0.0011; r<=0.0188; r=r+0.0001)
//         //    {
//         //     if(SellCount>OSellCount-0.1*Dif && BuyCount<SellCount)//((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//         //       {
//         ////                  CloseSellLoss1(r);
//         //       }
//         //    }
//         sellclosed=0;
//         for(r=0.0018; r>=0.0004; r=r-0.0001)
//           {
//    //        if(BuyCount<SellCount)// && BuyCount<SellCount-4*((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//              {
//               CloseSellProfit1(r,1);
//              }
//           }
//         for(r=0.0018; r>=0.0001; r=r-0.0001)
//           {
//   //         if(BuyCount<SellCount)// && BuyCount<SellCount-4*((MaxEquity1 - AccountEquity())/0.05*MaxEquity1)*0.05*Dif)
//              {
//               CloseSellProfit1(r,2);
//              }
//           }
//        }

      /**/

      //      MaxEquity1 = AccountEquity();


      //      if(MaxEquity1-AccountEquity() > 0.05*MaxEquity1)
      //        {
      //         if(BuyCount>SellCount)
      //           {
      //            for(int k=10000; k>=0; k-=1)
      //              {
      //               if(BuyCount>SellCount)
      //                 {
      //                  TradeSell(1*volume,1);
      //                 }
      //              }
      //           }
      //
      //         if(BuyCount<SellCount)
      //           {
      //            for(k=10000; k>=0; k-=1)
      //              {
      //               if(BuyCount<SellCount)
      //                 {
      //                  TradeBuy(1*volume,1);
      //                 }
      //              }
      //           }
      //         MaxEquity1 = AccountEquity();
      //        }

      //===============================================================================================================================================================

      if(AccountEquity()-Equity > 0 && BuyCount>SellCount && AccountMargin() < 0.75*AccountEquity() && MaxEquity1-AccountEquity()<0.05*MaxEquity1)
        {
         //      TradeSell(3*volume,1);
         TradeBuy(NormalizeDouble(0.00057*AccountEquity()*volume,2),1);
         //          TradeSell(7*volume);
         Equity = AccountEquity()+0;
        }

      if(AccountEquity()-Equity > 0 && BuyCount<=SellCount && AccountMargin() < 0.75*AccountEquity() && MaxEquity1-AccountEquity()<0.05*MaxEquity1)
        {
         //      TradeBuy(3*volume,1);
         TradeSell(NormalizeDouble(0.00057*AccountEquity()*volume,2),1);
         //           TradeBuy(7*volume);
         Equity = AccountEquity()+0;
        }

      if(AccountEquity()-Equity < 0 && BuyCount>SellCount)// && AccountMargin() < 0.95*AccountEquity())
        {

        
         //      TradeBuy(8*volume,1);
         TradeSell(5*volume,2);
         
         for(r=0.0138; r>=0.0002; r=r-0.0001)
           {
            if(AccountMargin() < 0.95*AccountEquity())
              {
               CloseSellLoss1(r);
              }
           }          
         
         
         
         for(r=0.0018; r>=0.0008; r=r-0.0001)
           {
            if(BuyCount>SellCount)// && MaxEquity1-AccountEquity()<0.05*MaxEquity1 && MaxEquity1-AccountEquity()<0.15*MaxEquity1)// && AccountMargin() < 0.95*AccountEquity())
              {
               CloseBuyProfit1(r,1);
              }
           }
         for(r=0.0012; r>=0.0011; r=r-0.0001)
           {
            if(BuyCount>SellCount)// && MaxEquity1-AccountEquity()<0.05*MaxEquity1 && MaxEquity1-AccountEquity()<0.15*MaxEquity1)// && AccountMargin() < 0.95*AccountEquity())
              {
               CloseBuyProfit1(r,2);
              }
           } 
      
           
           
                   
         
         Equity = AccountEquity();
        }

      if(AccountEquity()-Equity < 0 && BuyCount<=SellCount)// && AccountMargin() < 0.95*AccountEquity())
        {
 
        
         //     TradeSell(8*volume,1);
         TradeBuy(2*volume,2);
         
         for(r=0.0138; r>=0.0002; r=r-0.0001)
           {
            if(AccountMargin() < 0.95*AccountEquity())
              {
               CloseBuyLoss1(r);
              }
           }         
         
         
         for(r=0.0018; r>=0.0008; r=r-0.0001)
           {
            if(BuyCount<SellCount)// && MaxEquity1-AccountEquity()<0.05*MaxEquity1 && MaxEquity1-AccountEquity()<0.15*MaxEquity1)// && AccountMargin() < 0.95*AccountEquity())
              {
               CloseSellProfit1(r,1);
              }
           }
         for(r=0.0012; r>=0.0011; r=r-0.0001)
           {
            if(BuyCount<SellCount)// && MaxEquity1-AccountEquity()<0.05*MaxEquity1 && MaxEquity1-AccountEquity()<0.15*MaxEquity1)// && AccountMargin() < 0.95*AccountEquity())
              {
               CloseSellProfit1(r,2);
              }
           }         
      
 
        
         Equity = AccountEquity();
        }

      if(MathAbs(Bid-LastPrice)>0.0001)
        {
         for(int G=200; G>=0; G-=1)
           {
            //TradeBuy(1*volume,1);
            //TradeSell(1*volume,1);
            //LastPrice = Bid;
           }
        }
     }
  }



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
