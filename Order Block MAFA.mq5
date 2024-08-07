//+------------------------------------------------------------------+
//|                                             Order Block MAFA.mq4 |
//|                                                    Tony Programa |
//|                         https://www.instagram.com/tony_programa/ |
//+------------------------------------------------------------------+
#property copyright "Tony Programa"
#property link      "https://www.instagram.com/tony_programa/"
#property version   "2.01"
#property strict


#include <Controls\Label.mqh>
#include <ChartObjects\ChartObjectsFibo.mqh>

#property indicator_chart_window
#property indicator_buffers   16
#property indicator_plots     16
#property indicator_label1    "OB Bear Lower"
#property indicator_label2    "OB Bear Upper"
#property indicator_label3    "OB Bull Upper"
#property indicator_label4    "OB Bull Lower"
#property indicator_label5    "OP Sell"
#property indicator_label6    "SL Sell"
#property indicator_label7    "OP Buy"
#property indicator_label8    "SL Buy"
#property indicator_label9    "Poi Bear Lower"
#property indicator_label10    "Poi Bear Upper"
#property indicator_label11    "Poi Bull Upper"
#property indicator_label12    "Poi Bull Lower"
#property indicator_label13    "Imbalance Bear Lower"
#property indicator_label14    "Imbalance Bear Upper"
#property indicator_label15    "Imbalance Bull Upper"
#property indicator_label16    "Imbalance Bull Lower"

//--- input parameters
enum bz {PRICE, CLOSE};

enum Smart_Type
  {
   Smart=1, //Smart
   Clasic=0 //Clasic
  };

input int      CalculatedBars       = 1000;      //Número de Velas
input bool     ShowBrokenZone       = false;          //Mostrar Bloques anteriores
Smart_Type Type=0; // Block Type
bz       BrokenZone           = CLOSE;          //Broken zone by

input group    "----------Order Block----------"
input color    ColorBullishOB       = clrLightBlue;     //Bloques de Compra
input color    ColorBearishOB       = clrLightPink;     //Bloques de Venta
input bool     SolidZoneOB          = true;             //Mostrar Bloque Sólido

input group    "----------Break of Stucture----------"
ENUM_LINE_STYLE   LineStyleBoS      = 0;
int      WidthLineBoS         = 2;              //Line width
input color    ColorBullishBoS      = clrBlue;        //Color BoS de compra
input color    ColorBearishBoS      = clrRed;         //Color BoS de venta

//"Point of Interest"
color    ColorBullishTemp      = clrDeepSkyBlue;  //Color bullish
color    ColorBearishTemp      = clrDeepPink;     //Color bearish
bool     SolidZoneTemp         = false;           //Solid zone

//"Imbalance"
color    ColorBullishImb      = clrLightCyan;   //Color bullish
color    ColorBearishImb      = clrMistyRose;    //Color bearish
bool     SolidZoneImb         = true;           //Solid zone

double   EntryLevelFibo       = 110.0;           //Fibo level entry
double   SLLevelFibo          = -10.0;           //Fibo level stop
color    ColorEntryLevelUp    = C'38,166,154';   //Color buy
color    ColorEntryLevelDn    = C'239,83,80';    //Color sell

input group    "---------- Filtro de Sesiones ----------"
input bool        Filter_Session    = false;                 //Aplicar Filtro de Sesiones
input group    "---------- Sidney ----------"
bool              TradeOnSidney     = true;                 // ==SYDNEY==
input uint              InpStartSidney    =  0;                   // Hora inicial de Sesión
input uint              InpEndSidney      =  9;                   // Hora final de Sesión
color             InpColorSidney    =  clrOrange;           // Color de la Sesión

input group    "---------- Tokio ----------"
bool              TradeOnTokyo      = false;                 // ==TOKIO==
input uint              InpStartTokio     =  2;                   // Hora inicial de Sesión
input uint              InpEndTokio       =  11;                  // Hora final de Sesión
color             InpColorTokio     =  clrOrangeRed;        // Color de la Sesión

input group    "---------- Londres ----------"
bool              TradeOnLondon     = false;                 // ==LONDRES==
input uint              InpStartLondon    =  10;                  // Hora inicial de Sesión
input uint              InpEndLondon      =  19;                  // Hora final de Sesión
color             InpColorLondon    =  clrMediumSeaGreen;   // Color de la Sesiónr

input group    "---------- Nueva York ----------"
bool              TradeOnNewYork    = false;                 // ==NEW YORK==
input uint              InpStartNewYork   =  15;                  // Hora inicial de Sesión
input uint              InpEndNewYork     =  24;                  // Hora final de Sesión
color             InpColorNewYork   =  clrSkyBlue;          // Color de la Sesión


int               ShowSession       = 5;                 //==Núm. de Sesiones anteriores==
bool              InpShowLabels     =  true;             // Nombre de las sesiones
string            InpFontName       =  "Calibri";        // Tipo de letra
uchar             InpFontSize       =  8;                // Tamaño de letra
color             InpFontColor      =  clrNavy;          // Color de letra
bool              InpShowVLines     =  true;             // Lineas separadoras


enum Lista_Permiso
  {
   Permitir=1, //Permit
   No_Permitir=0 //Not Permit
  };

input group    "---------- Patrones armónicos ----------"
input Lista_Permiso Pattern_Gartley=0; //Patron Gartley
double FiboXA_B_Gartley_Min=57; //Fibo XA for B minimum
double FiboXA_B_Gartley_Max=66; //Fibo XA for B High
double FiboAB_C_Gartley_Min=38.2; //Fibo AB for C minimum
double FiboAB_C_Gartley_Max=88.6; //Fibo AB for C High
double FiboXA_D_Gartley=78.6; //Fibo XA for D



input Lista_Permiso Pattern_Bat=0; //Patron Bat
double FiboXA_B_BAT_Min=38; //Fibo XA for B minimum
double FiboXA_B_BAT_Max=65; //Fibo XA for B High
double FiboAB_C_BAT_Min=38.2; //Fibo AB for C minimum
double FiboAB_C_BAT_Max=88.6; //Fibo AB for C High
double FiboXA_D_BAT=88.6; //Fibo XA for D



input Lista_Permiso Pattern_Butterfly=0; //Patron Butterfly
double FiboXA_B_Butterfly_Min=75; //Fibo XA for B minimum
double FiboXA_B_Butterfly_Max=81; //Fibo XA for B High
double FiboAB_C_Butterfly_Min=38.2; //Fibo AB for C minimum
double FiboAB_C_Butterfly_Max=88.6; //Fibo AB for C High
double FiboXA_D_Butterfly=127.2; //Fibo XA for D



input Lista_Permiso Pattern_Crab=0; //Patron Crab
double FiboXA_B_Crab_Min=59; //Fibo XA for B minimum
double FiboXA_B_Crab_Max=72; //Fibo XA for B High
double FiboAB_C_Crab_Min=38.2; //Fibo AB for C minimum
double FiboAB_C_Crab_Max=88.6; //Fibo AB for C High
double FiboXA_D_Crab=161.8; //Fibo XA for D



input Lista_Permiso Pattern_Shark=0; //Patron Shark
double FiboXA_B_Shark_Min=38.2; //Fibo XA for B minimum
double FiboXA_B_Shark_Max=61.8; //Fibo XA for B High
double FiboAB_C_Shark_Min=113; //Fibo AB for C minimum
double FiboAB_C_Shark_Max=161.8; //Fibo AB for C High
double FiboXC_D_Shark_First=113; //Fibo XC for D first
double FiboXC_D_Shark_Second=161; //Fibo XC for D second



input Lista_Permiso Pattern_Cypher=0; //Patron Cypher
double FiboXA_B_Cypher_Min=59; //Fibo XA for B minimum
double FiboXA_B_Cypher_Max=72; //Fibo XA for B High
double FiboAB_C_Cypher_Min=124.5; //Fibo AB for C minimum
double FiboAB_C_Cypher_Max=130; //Fibo AB for C High
double FiboXC_D_Cypher=78.6; //Fibo XC for D



Lista_Permiso Pattern_Aureo=0; //Aureo Pattern
double FiboXA_B_Aureo_Min=72; //Fibo XA for B minimum
double FiboXA_B_Aureo_Max=75; //Fibo XA for B High
double Extension_Fibo=127.2; //Extension Fibo First at Point C
double Extension_Fibo2=161.8; //Extension Fibo Second at Point C



ENUM_TIMEFRAMES Temporalidad=0; //Periodicity
int Profundidad=300; //Numbers of Candles
double Fibo_Point=35; // Fibo Point for Paint
int N=35; //Before Number Candles of Point X
int Profundidad1;


bool Time_For_Gartley=true;
bool Time_For_Bat=true;
bool Time_For_Butterfly=true;
bool Time_For_Crab=true;
bool Time_For_Shark=true;
bool Time_For_Cypher=true;
bool Time_For_Poseidon=true;
bool Time_For_Aureo=true;

bool Gartley=true;
bool Bat=true;
bool Butterfly=true;
bool Crab=true;
bool Shark=true;
bool Cypher=true;
bool Aureo=true;

CLabel lblTrend1, lblTrend2, lblEntry1, lblEntry2, lblImb1, lblImb2, lblTemp1, lblTemp2;
CChartObjectFibo fiboUp, fiboDn;

double Buffer0[],
       Buffer1[],
       Buffer2[],
       Buffer3[],
       BufferOPSell[],
       BufferSLSell[],
       BufferOPBuy[],
       BufferSLBuy[],
       BufferSupplyDn[],
       BufferSupplyUp[],
       BufferDemandUp[],
       BufferDemandDn[],
       BufferTempSupplyDn[],
       BufferTempSupplyUp[],
       BufferTempDemandUp[],
       BufferTempDemandDn[],
       BufferImbSupplyDn[],
       BufferImbSupplyUp[],
       BufferImbDemandUp[],
       BufferImbDemandDn[];


int   CopyBufferSupply[],
      CopyBufferDemand[];

int HndFractalOB;
bool _brokenby;
datetime _time_[], _alertOB, _alertBoS, _alertImb, _alertTemp;
double _level[12] = {0},
                    _open_[], _high_[], _low_[], _close_[], preclose, range;


bool Time=true;

int  start_sidney;
int  end_sidney;
int  start_tokio;
int  end_tokio;
int  start_london;
int  end_london;
int  start_new_york;
int  end_new_york;
int  width;
int  font_size;
int bar1;
double mp;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   datetime Expiry=D'2025.03.21 00:00';
   if(TimeCurrent()>Expiry)
     {
      Alert("El Indicador ha Expirado");
      return(INIT_FAILED);
     }
//---
   
      const long allowed_accounts[] = {406101, 30055700, 61171123, 61370482, 61373195, 51814586};
      int password_status = -1;
      long account = AccountInfoInteger(ACCOUNT_LOGIN);

      for(int i=0; i<ArraySize(allowed_accounts); i++)
        {
         if(account == allowed_accounts[i])
           {
            password_status = 1;
            break;
           }
        }

      if(password_status == -1)
        {
         Alert("La licencia no puede verificarse, no puede operar por ID incorrecto");
         return(INIT_FAILED);
        }
   

//--- indicator Harmonic Pattern
   ChartSetInteger(0, CHART_SHIFT, true);

   ObjectDelete(0,"Triangle X-A-B_Gartley_Buy");
   ObjectDelete(0,"Triangle B-C-D_Gartley_Buy");
   ObjectDelete(0,"Triangle X-A-B_Gartley_Sell");
   ObjectDelete(0,"Triangle B-C-D_Gartley_Sell");
   ObjectDelete(0,"Gartley_Buy");
   ObjectDelete(0,"Gartley_Sell");
   ObjectDelete(0,"Gartley_Buy_Ray");
   ObjectDelete(0,"Gartley_Sell_Ray");
   ObjectDelete(0,"Gartley_Buy_Text");
   ObjectDelete(0,"Gartley_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Bat_Buy");
   ObjectDelete(0,"Triangle B-C-D_Bat_Buy");
   ObjectDelete(0,"Triangle X-A-B_Bat_Sell");
   ObjectDelete(0,"Triangle B-C-D_Bat_Sell");
   ObjectDelete(0,"Bat_Buy");
   ObjectDelete(0,"Bat_Sell");
   ObjectDelete(0,"Bat_Buy_Ray");
   ObjectDelete(0,"Bat_Sell_Ray");
   ObjectDelete(0,"Bat_Buy_Text");
   ObjectDelete(0,"Bat_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Butterfly_Buy");
   ObjectDelete(0,"Triangle B-C-D_Butterfly_Buy");
   ObjectDelete(0,"Triangle X-A-B_Butterfly_Sell");
   ObjectDelete(0,"Triangle B-C-D_Butterfly_Sell");
   ObjectDelete(0,"Butterfly_Buy");
   ObjectDelete(0,"Butterfly_Sell");
   ObjectDelete(0,"Butterfly_Buy_Ray");
   ObjectDelete(0,"Butterfly_Sell_Ray");
   ObjectDelete(0,"Butterfly_Buy_Text");
   ObjectDelete(0,"Butterfly_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Crab_Buy");
   ObjectDelete(0,"Triangle B-C-D_Crab_Buy");
   ObjectDelete(0,"Triangle X-A-B_Crab_Sell");
   ObjectDelete(0,"Triangle B-C-D_Crab_Sell");
   ObjectDelete(0,"Crab_Buy");
   ObjectDelete(0,"Crab_Sell");
   ObjectDelete(0,"Crab_Buy_Ray");
   ObjectDelete(0,"Crab_Sell_Ray");
   ObjectDelete(0,"Crab_Buy_Text");
   ObjectDelete(0,"Crab_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Shark_Buy");
   ObjectDelete(0,"Triangle B-C-D_Shark_Buy");
   ObjectDelete(0,"Triangle X-A-B_Shark_Sell");
   ObjectDelete(0,"Triangle B-C-D_Shark_Sell");
   ObjectDelete(0,"Shark_Buy");
   ObjectDelete(0,"Shark_Sell");
   ObjectDelete(0,"Shark_Buy_Ray");
   ObjectDelete(0,"Shark_Sell_Ray");
   ObjectDelete(0,"Shark_Buy_Text");
   ObjectDelete(0,"Shark_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Cypher_Buy");
   ObjectDelete(0,"Triangle B-C-D_Cypher_Buy");
   ObjectDelete(0,"Triangle X-A-B_Cypher_Sell");
   ObjectDelete(0,"Triangle B-C-D_Cypher_Sell");
   ObjectDelete(0,"Cypher_Buy");
   ObjectDelete(0,"Cypher_Sell");
   ObjectDelete(0,"Cypher_Buy_Ray");
   ObjectDelete(0,"Cypher_Sell_Ray");
   ObjectDelete(0,"Cypher_Buy_Text");
   ObjectDelete(0,"Cypher_Sell_Text");


   ObjectDelete(0,"Line X-A_Sell");
   ObjectDelete(0,"Line X-A_Buy");
   ObjectDelete(0,"Line X-C_Sell");
   ObjectDelete(0,"Line X-C_Buy");
   ObjectDelete(0,"Line B-A_Sell");
   ObjectDelete(0,"Line B-A_Buy");
   ObjectDelete(0,"Line B-C_Sell");
   ObjectDelete(0,"Line B-C_Buy");
   ObjectDelete(0,"Aureo_Sell");
   ObjectDelete(0,"Aureo_Buy");
   ObjectDelete(0,"Aureo_Sell_Ray");
   ObjectDelete(0,"Aureo_Buy_Ray");
   ObjectDelete(0,"Aureo_Sell_Text");
   ObjectDelete(0,"Aureo_Buy_Text");

   Time_For_Gartley=true;
   Time_For_Bat=true;
   Time_For_Butterfly=true;
   Time_For_Crab=true;
   Time_For_Shark=true;
   Time_For_Cypher=true;
   Time_For_Poseidon=true;
   Time_For_Aureo=true;


   int Number_Candle = Bars(Symbol(),Temporalidad);

   if((Profundidad+N)>Number_Candle)
      Profundidad1=Number_Candle-N;
   else
      Profundidad1=Profundidad;


   if(Pattern_Gartley==1 && Time_For_Gartley)
     {
      Pattern_Gartley_Sell();
      Pattern_Gartley_Buy();
      Time_For_Gartley=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Bat==1 && Time_For_Bat)
     {
      Pattern_Bat_Sell();
      Pattern_Bat_Buy();
      Time_For_Bat=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Butterfly==1 && Time_For_Butterfly)
     {
      Pattern_Butterfly_Sell();
      Pattern_Butterfly_Buy();
      Time_For_Butterfly=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Crab==1 && Time_For_Crab)
     {
      Pattern_Crab_Sell();
      Pattern_Crab_Buy();
      Time_For_Crab=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Shark==1 && Time_For_Shark)
     {
      Pattern_Shark_Sell();
      Pattern_Shark_Buy();
      Time_For_Shark=false;
      EventSetTimer(60*2);
     }

   if(Pattern_Cypher==1 && Time_For_Cypher)
     {
      Pattern_Cypher_Sell();
      Pattern_Cypher_Buy();
      Time_For_Cypher=false;
      EventSetTimer(60*5);
     }


   if(Pattern_Aureo==1 && Time_For_Aureo)
     {
      Pattern_Aureo_Sell();
      Pattern_Aureo_Buy();
      Time_For_Aureo=false;
      EventSetTimer(60*2);
     }


//--- indicator buffers mapping
   HndFractalOB = iFractals(_Symbol, PERIOD_CURRENT);
   gvn = _Symbol;

   if(MQLInfoInteger(MQL_TESTER))
      gvn = "test" + _Symbol;

   if(!GlobalVariableCheck(gvn + objname[0]))
      GlobalVariableSet(gvn + objname[0], 3);

   CreatePanel();

   _level[0] = EntryLevelFibo / 100.0;
   _level[1] = SLLevelFibo / 100.0;

   range = MathAbs(_level[1] - _level[0]);

   for(int x = 1; x < 11; x++)
      _level[x + 1] = _level[0] + range * x;

   _copybuffer();
   _brokenby = BrokenZone == PRICE ? true : false;
   _SetIndex();
   ChartSetInteger(0, CHART_SHIFT, true);

   if(Filter_Session)
     {
      start_sidney = int(InpStartSidney > 24 ? 0 : InpStartSidney);
      end_sidney = int(InpEndSidney > 24 ? 0 : InpEndSidney);
      start_tokio = int(InpStartTokio > 24 ? 0 : InpStartTokio);
      end_tokio = int(InpEndTokio > 24 ? 0 : InpEndTokio);
      start_london = int(InpStartLondon > 24 ? 0 : InpStartLondon);
      end_london = int(InpEndLondon > 24 ? 0 : InpEndLondon);
      start_new_york = int(InpStartNewYork > 24 ? 0 : InpStartNewYork);
      end_new_york = int(InpEndNewYork > 24 ? 0 : InpEndNewYork);
      font_size = int(InpFontSize < 5 ? 5 : InpFontSize);
     }
   int Diferencia = (TimeCurrent()-TimeLocal())/3600;

   if(TimeLocal() > TimeCurrent())
     {
      start_sidney = start_sidney - Diferencia;
      if(start_sidney<0)
         start_sidney = 24 + start_sidney;
      if(start_sidney>24)
         start_sidney =start_sidney - 24;

      end_sidney = end_sidney - Diferencia;
      if(end_sidney<0)
         end_sidney = 24 + end_sidney;
      if(end_sidney>24)
         end_sidney =end_sidney - 24;

      start_tokio = start_tokio - Diferencia;
      if(start_tokio<0)
         start_tokio = 24 + start_tokio;
      if(start_tokio>24)
         start_tokio =start_tokio - 24;

      end_tokio = end_tokio - Diferencia;
      if(end_tokio<0)
         end_tokio = 24 + end_tokio;
      if(end_tokio>24)
         end_tokio = end_tokio - 24;

      start_london = start_london - Diferencia;
      if(start_london<0)
         start_london = 24 + start_london;
      if(start_london>24)
         start_london =start_london - 24;

      end_london = end_london - Diferencia;
      if(end_london<0)
         end_london = 24 + end_london;
      if(end_london>24)
         end_london =end_london - 24;

      start_new_york = start_new_york - Diferencia;
      if(start_new_york<0)
         start_new_york = 24 + start_new_york;
      if(start_new_york>24)
         start_new_york =start_new_york - 24;

      end_new_york = end_new_york - Diferencia;
      if(end_new_york<0)
         end_new_york = 24 + end_new_york;
      if(end_new_york>24)
         end_new_york =end_new_york - 24;

     }

   if(TimeLocal() < TimeCurrent())
     {
      start_sidney = start_sidney + Diferencia;
      if(start_sidney<0)
         start_sidney = 24 + start_sidney;
      if(start_sidney>24)
         start_sidney =start_sidney - 24;

      end_sidney = end_sidney + Diferencia;
      if(end_sidney<0)
         end_sidney = 24 + end_sidney;
      if(end_sidney>24)
         end_sidney =end_sidney - 24;

      start_tokio = start_tokio + Diferencia;
      if(start_tokio<0)
         start_tokio = 24 + start_tokio;
      if(start_tokio>24)
         start_tokio =start_tokio - 24;

      end_tokio = end_tokio + Diferencia;
      if(end_tokio<0)
         end_tokio = 24 + end_tokio;
      if(end_tokio>24)
         end_tokio = end_tokio - 24;

      start_london = start_london + Diferencia;
      if(start_london<0)
         start_london = 24 + start_london;
      if(start_london>24)
         start_london =start_london - 24;

      end_london = end_london + Diferencia;
      if(end_london<0)
         end_london = 24 + end_london;
      if(end_london>24)
         end_london =end_london - 24;

      start_new_york = start_new_york + Diferencia;
      if(start_new_york<0)
         start_new_york = 24 + start_new_york;
      if(start_new_york>24)
         start_new_york =start_new_york - 24;

      end_new_york = end_new_york + Diferencia;
      if(end_new_york<0)
         end_new_york = 24 + end_new_york;
      if(end_new_york>24)
         end_new_york =end_new_york - 24;
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _SetIndex()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   SetIndexBuffer(0, Buffer0, INDICATOR_DATA);
   SetIndexBuffer(1, Buffer1, INDICATOR_DATA);
   SetIndexBuffer(2, Buffer2, INDICATOR_DATA);
   SetIndexBuffer(3, Buffer3, INDICATOR_DATA);
   SetIndexBuffer(4, BufferOPSell, INDICATOR_DATA);
   SetIndexBuffer(5, BufferSLSell, INDICATOR_DATA);
   SetIndexBuffer(6, BufferOPBuy, INDICATOR_DATA);
   SetIndexBuffer(7, BufferSLBuy, INDICATOR_DATA);
   SetIndexBuffer(8, BufferTempSupplyDn, INDICATOR_DATA);
   SetIndexBuffer(9, BufferTempSupplyUp, INDICATOR_DATA);
   SetIndexBuffer(10, BufferTempDemandUp, INDICATOR_DATA);
   SetIndexBuffer(11, BufferTempDemandDn, INDICATOR_DATA);
   SetIndexBuffer(12, BufferImbSupplyDn, INDICATOR_DATA);
   SetIndexBuffer(13, BufferImbSupplyUp, INDICATOR_DATA);
   SetIndexBuffer(14, BufferImbDemandUp, INDICATOR_DATA);
   SetIndexBuffer(15, BufferImbDemandDn, INDICATOR_DATA);

   for(int x = 0; x < 16; x++)
      PlotIndexSetDouble(x, PLOT_EMPTY_VALUE, 0);

   ArraySetAsSeries(Buffer0, true);
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(BufferOPSell, true);
   ArraySetAsSeries(BufferSLSell, true);
   ArraySetAsSeries(BufferOPBuy, true);
   ArraySetAsSeries(BufferSLBuy, true);
   ArraySetAsSeries(BufferTempSupplyDn, true);
   ArraySetAsSeries(BufferTempSupplyUp, true);
   ArraySetAsSeries(BufferTempDemandUp, true);
   ArraySetAsSeries(BufferTempDemandDn, true);
   ArraySetAsSeries(BufferImbSupplyDn, true);
   ArraySetAsSeries(BufferImbSupplyUp, true);
   ArraySetAsSeries(BufferImbDemandUp, true);
   ArraySetAsSeries(BufferImbDemandDn, true);

   ArrayResize(BufferSupplyDn, CalculatedBars);
   ArrayResize(BufferSupplyUp, CalculatedBars);
   ArrayResize(BufferDemandUp, CalculatedBars);
   ArrayResize(BufferDemandDn, CalculatedBars);
   ArrayResize(CopyBufferSupply, CalculatedBars);
   ArrayResize(CopyBufferDemand, CalculatedBars);

   ArraySetAsSeries(BufferSupplyDn, true);
   ArraySetAsSeries(BufferSupplyUp, true);
   ArraySetAsSeries(BufferDemandUp, true);
   ArraySetAsSeries(BufferDemandDn, true);
   ArraySetAsSeries(CopyBufferSupply, true);
   ArraySetAsSeries(CopyBufferDemand, true);

   ArrayResize(_time_, CalculatedBars);
   ArrayResize(_open_, CalculatedBars);
   ArrayResize(_high_, CalculatedBars);
   ArrayResize(_low_, CalculatedBars);
   ArrayResize(_close_, CalculatedBars);
   ArraySetAsSeries(_time_, true);
   ArraySetAsSeries(_open_, true);
   ArraySetAsSeries(_high_, true);
   ArraySetAsSeries(_low_, true);
   ArraySetAsSeries(_close_, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"MAFA");
   ObjectsDeleteAll(0, "BOS");
   ObjectsDeleteAll(0, "OB");
   ObjectsDeleteAll(0, "_Imb");
   ObjectsDeleteAll(0, "_Temp");
   RemoveFibo(-1);
   lblTrend1.Destroy(reason);
   lblTrend2.Destroy(reason);
   lblEntry1.Destroy(reason);
   lblEntry2.Destroy(reason);
   lblImb1.Destroy(reason);
   lblImb2.Destroy(reason);
   lblTemp1.Destroy(reason);
   lblTemp2.Destroy(reason);
   ChartRedraw();

   ObjectDelete(0,"Triangle X-A-B_Gartley_Buy");
   ObjectDelete(0,"Triangle B-C-D_Gartley_Buy");
   ObjectDelete(0,"Triangle X-A-B_Gartley_Sell");
   ObjectDelete(0,"Triangle B-C-D_Gartley_Sell");
   ObjectDelete(0,"Gartley_Buy");
   ObjectDelete(0,"Gartley_Sell");
   ObjectDelete(0,"Gartley_Buy_Ray");
   ObjectDelete(0,"Gartley_Sell_Ray");
   ObjectDelete(0,"Gartley_Buy_Text");
   ObjectDelete(0,"Gartley_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Bat_Buy");
   ObjectDelete(0,"Triangle B-C-D_Bat_Buy");
   ObjectDelete(0,"Triangle X-A-B_Bat_Sell");
   ObjectDelete(0,"Triangle B-C-D_Bat_Sell");
   ObjectDelete(0,"Bat_Buy");
   ObjectDelete(0,"Bat_Sell");
   ObjectDelete(0,"Bat_Buy_Ray");
   ObjectDelete(0,"Bat_Sell_Ray");
   ObjectDelete(0,"Bat_Buy_Text");
   ObjectDelete(0,"Bat_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Butterfly_Buy");
   ObjectDelete(0,"Triangle B-C-D_Butterfly_Buy");
   ObjectDelete(0,"Triangle X-A-B_Butterfly_Sell");
   ObjectDelete(0,"Triangle B-C-D_Butterfly_Sell");
   ObjectDelete(0,"Butterfly_Buy");
   ObjectDelete(0,"Butterfly_Sell");
   ObjectDelete(0,"Butterfly_Buy_Ray");
   ObjectDelete(0,"Butterfly_Sell_Ray");
   ObjectDelete(0,"Butterfly_Buy_Text");
   ObjectDelete(0,"Butterfly_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Crab_Buy");
   ObjectDelete(0,"Triangle B-C-D_Crab_Buy");
   ObjectDelete(0,"Triangle X-A-B_Crab_Sell");
   ObjectDelete(0,"Triangle B-C-D_Crab_Sell");
   ObjectDelete(0,"Crab_Buy");
   ObjectDelete(0,"Crab_Sell");
   ObjectDelete(0,"Crab_Buy_Ray");
   ObjectDelete(0,"Crab_Sell_Ray");
   ObjectDelete(0,"Crab_Buy_Text");
   ObjectDelete(0,"Crab_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Shark_Buy");
   ObjectDelete(0,"Triangle B-C-D_Shark_Buy");
   ObjectDelete(0,"Triangle X-A-B_Shark_Sell");
   ObjectDelete(0,"Triangle B-C-D_Shark_Sell");
   ObjectDelete(0,"Shark_Buy");
   ObjectDelete(0,"Shark_Sell");
   ObjectDelete(0,"Shark_Buy_Ray");
   ObjectDelete(0,"Shark_Sell_Ray");
   ObjectDelete(0,"Shark_Buy_Text");
   ObjectDelete(0,"Shark_Sell_Text");

   ObjectDelete(0,"Triangle X-A-B_Cypher_Buy");
   ObjectDelete(0,"Triangle B-C-D_Cypher_Buy");
   ObjectDelete(0,"Triangle X-A-B_Cypher_Sell");
   ObjectDelete(0,"Triangle B-C-D_Cypher_Sell");
   ObjectDelete(0,"Cypher_Buy");
   ObjectDelete(0,"Cypher_Sell");
   ObjectDelete(0,"Cypher_Buy_Ray");
   ObjectDelete(0,"Cypher_Sell_Ray");
   ObjectDelete(0,"Cypher_Buy_Text");
   ObjectDelete(0,"Cypher_Sell_Text");

   ObjectDelete(0,"Line X-A_Sell");
   ObjectDelete(0,"Line X-A_Buy");
   ObjectDelete(0,"Line X-C_Sell");
   ObjectDelete(0,"Line X-C_Buy");
   ObjectDelete(0,"Line B-A_Sell");
   ObjectDelete(0,"Line B-A_Buy");
   ObjectDelete(0,"Line B-C_Sell");
   ObjectDelete(0,"Line B-C_Buy");
   ObjectDelete(0,"Aureo_Sell");
   ObjectDelete(0,"Aureo_Buy");
   ObjectDelete(0,"Aureo_Sell_Ray");
   ObjectDelete(0,"Aureo_Buy_Ray");
   ObjectDelete(0,"Aureo_Sell_Text");
   ObjectDelete(0,"Aureo_Buy_Text");

   Time_For_Gartley=true;
   Time_For_Bat=true;
   Time_For_Butterfly=true;
   Time_For_Crab=true;
   Time_For_Shark=true;
   Time_For_Cypher=true;
   Time_For_Poseidon=true;
   Time_For_Aureo=true;

   if(Filter_Session)
     {
      ObjectsDeleteAll(0, "Market_Price_Label");
      ObjectsDeleteAll(0, "Time_Label");
      ObjectsDeleteAll(0, "Porcent_Price_Label");
      ObjectsDeleteAll(0, "Spread_Price_Label");
      ObjectsDeleteAll(0, "Simbol_Price_Label");
      ObjectsDeleteAll(0, "background");
      ObjectsDeleteAll(0, "txt");
      ObjectsDeleteAll(0, "session");
      ObjectsDeleteAll(0, "btn_");
      ObjectDelete(0, "Status");
      ObjectDelete(0, "Status2");
      ChartRedraw();
      bar1 = 0;
      mp = 0;
     }

   ObjectDelete(0,"MAFA");

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(Filter_Session)
     {
      if(FilterSession() && PermitOperation())
         CreateSession();
     }
   else
     {
      ObjectsDeleteAll(0, "Market_Price_Label");
      ObjectsDeleteAll(0, "Time_Label");
      ObjectsDeleteAll(0, "Porcent_Price_Label");
      ObjectsDeleteAll(0, "Spread_Price_Label");
      ObjectsDeleteAll(0, "Simbol_Price_Label");
      ObjectsDeleteAll(0, "background");
      ObjectsDeleteAll(0, "txt");
      ObjectsDeleteAll(0, "session");
      ObjectsDeleteAll(0, "btn_");
      ObjectDelete(0, "Status");
      ObjectDelete(0, "Status2");
      ChartRedraw();
      bar1 = 0;
      mp = 0;

     }

   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(time, true);

   int valOB = int(GlobalVariableGet(gvn + objname[0])),
       valRR = int(GlobalVariableGet(gvn + objname[2])),
       valImb = int(GlobalVariableGet(gvn + objname[4])),
       valTemp = int(GlobalVariableGet(gvn + objname[6])),
       IndicatorCalculated = rates_total - prev_calculated;

   if(IndicatorCalculated > 0)
     {
      ArrayInitialize(Buffer0, 0);
      ArrayInitialize(Buffer1, 0);
      ArrayInitialize(Buffer2, 0);
      ArrayInitialize(Buffer3, 0);

      ObjectsDeleteAll(0, "OB");
      ObjectsDeleteAll(0, "BOS");
      ObjectsDeleteAll(0, "_Imb");
      ObjectsDeleteAll(0, "_Temp");

      CreateZone(valOB, valImb);
      CreateTemp(valTemp);
     }

   if(close[0] >= BufferSupplyUp[0] && BufferSupplyUp[0] > 0)
     {
      ArrayRemove(BufferSupplyDn, 0, 1);
      ArrayRemove(BufferSupplyUp, 0, 1);
     }
   else
      if(close[0] <= BufferDemandDn[0] && BufferDemandDn[0] > 0)
        {
         ArrayRemove(BufferDemandUp, 0, 1);
         ArrayRemove(BufferDemandDn, 0, 1);
        }

   if(valOB != 0)
      if(valRR == 0)
        {
         fiboUp.Delete();
         fiboDn.Delete();
        }
      else
        {
         if(BufferSupplyUp[valRR - 1] == 0 && BufferSupplyDn[valRR - 1] == 0)
            fiboDn.Delete();

         if(BufferDemandDn[valRR - 1] == 0 && BufferDemandUp[valRR - 1] == 0)
            fiboUp.Delete();

         CreateRR(valOB, valRR);
        }

   double _range = MathAbs(BufferSupplyUp[0] - BufferSupplyDn[0]),
          _oprange = EntryLevelFibo * _range / 100.0,
          _slrange = SLLevelFibo * _range / 100.0;

   BufferOPSell[0] = BufferSupplyUp[0] - _oprange;
   BufferSLSell[0] = BufferSupplyUp[0] - _slrange;

   _range = MathAbs(BufferDemandDn[0] - BufferDemandUp[0]);
   _oprange = EntryLevelFibo * _range / 100.0;
   _slrange = SLLevelFibo * _range / 100.0;

   BufferOPBuy[0] = BufferDemandDn[0] + _oprange;
   BufferSLBuy[0] = BufferDemandDn[0] + _slrange;

   preclose = close[0];
//--- return value of prev_calculated for next call

//--- Harmonic Pattern
   if(Pattern_Gartley==1 && Time_For_Gartley)
     {
      Pattern_Gartley_Sell();
      Pattern_Gartley_Buy();
      Time_For_Gartley=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Bat==1 && Time_For_Bat)
     {
      Pattern_Bat_Sell();
      Pattern_Bat_Buy();
      Time_For_Bat=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Butterfly==1 && Time_For_Butterfly)
     {
      Pattern_Butterfly_Sell();
      Pattern_Butterfly_Buy();
      Time_For_Butterfly=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Crab==1 && Time_For_Crab)
     {
      Pattern_Crab_Sell();
      Pattern_Crab_Buy();
      Time_For_Crab=false;
      EventSetTimer(60*5);
     }

   if(Pattern_Shark==1 && Time_For_Shark)
     {
      Pattern_Shark_Sell();
      Pattern_Shark_Buy();
      Time_For_Shark=false;
      EventSetTimer(60*2);
     }

   if(Pattern_Cypher==1 && Time_For_Cypher)
     {
      Pattern_Cypher_Sell();
      Pattern_Cypher_Buy();
      Time_For_Cypher=false;
      EventSetTimer(60*5);
     }



   if(Pattern_Aureo==1 && Time_For_Aureo)
     {
      Pattern_Aureo_Sell();
      Pattern_Aureo_Buy();
      Time_For_Aureo=false;
      EventSetTimer(60*2);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long & lparam,
                  const double & dparam,
                  const string & sparam)
  {
//---
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == objname[0] || sparam == objname[1])
        {
         int val = int(GlobalVariableGet(gvn + objname[0]) + 1);
         int _valRR = int(GlobalVariableGet(gvn + objname[2]));
         val = val > 3 ? 0 : val;
         GlobalVariableSet(gvn + objname[0], val);

         ArrayInitialize(Buffer0, 0);
         ArrayInitialize(Buffer1, 0);
         ArrayInitialize(Buffer2, 0);
         ArrayInitialize(Buffer3, 0);

         if(val == 0)
           {
            ObjectsDeleteAll(0, "BOS");
            ObjectsDeleteAll(0, "OB");
            if(_valRR != 0)
              {
               fiboUp.Delete();
               fiboDn.Delete();
              }
           }
         else
           {
            if(val == 1)
              {
               ObjectsDeleteAll(0, "BOSdn");
               ObjectsDeleteAll(0, "OBdn");
               if(_valRR != 0)
                 {
                  fiboDn.Delete();
                  CreateRR(val, _valRR);
                 }
              }
            else
               if(val == 2)
                 {
                  ObjectsDeleteAll(0, "BOSup");
                  ObjectsDeleteAll(0, "OBup");
                  if(_valRR != 0)
                    {
                     fiboUp.Delete();
                     CreateRR(val, _valRR);
                    }
                 }
            ChartRedraw();
            CreateZone(val, 0);
           }

         color warna;
         string Font, txt;
         CekTrend(warna, txt, Font);
         lblTrend1.Color(warna);
         lblTrend2.Color(warna);
         lblTrend2.Text(txt);
         lblTrend2.Font(Font);

         if(val == 0)
            lblTrend2.Move(10, 28);
         else
            lblTrend2.Move(10, 25);
        }
      else
         if(sparam == objname[2] || sparam == objname[3])
           {
            int _val = int(GlobalVariableGet(gvn + objname[0]));
            if(_val != 0)
              {
               int val = int(GlobalVariableGet(gvn + objname[2]) + 1);
               val = val > totalZone ? 0 : val;
               GlobalVariableSet(gvn + objname[2], val);
               color warna;
               string Font, txt = string(val);

               int x1, y1, fz;

               if(val == 0)
                 {
                  fiboUp.Delete();
                  fiboDn.Delete();
                  ChartRedraw();
                  warna = clrGray;
                  txt = "O";
                  Font = "Wingdings 2";
                  x1 = 10;
                  y1 = 53;
                  fz = 18;
                  lblEntry2.Move(x1, y1);
                 }
               else
                 {
                  fiboUp.Delete();
                  fiboDn.Delete();
                  warna = clrDodgerBlue;
                  txt = string(val);
                  Font = "Cambria";
                  x1 = 13;
                  y1 = 55;
                  fz = 11;
                  lblEntry2.Move(x1, y1);
                  CreateRR(int(GlobalVariableGet(gvn + objname[0])), val);
                 }

               lblEntry1.Color(warna);
               lblEntry2.Color(warna);
               lblEntry2.Text(txt);
               lblEntry2.Font(Font);
               lblEntry2.FontSize(fz);
              }
           }

         else
            if(sparam == objname[4] || sparam == objname[5])
              {
               int val = int(GlobalVariableGet(gvn + objname[4]) + 1);
               val = val > 1 ? 0 : val;
               GlobalVariableSet(gvn + objname[4], val);

               if(val == 0)
                  ObjectsDeleteAll(0, "_Imb");
               else
                 {
                  ChartRedraw();
                  CreateZone(int(GlobalVariableGet(gvn + objname[0])), val);
                 }

               color warna;
               string Font, txt;
               CekOnOff(4, warna, txt, Font);
               lblImb1.Color(warna);
               lblImb2.Color(warna);
               lblImb2.Text(txt);
               lblImb2.Font(Font);
              }

            else
               if(sparam == objname[4] || sparam == objname[5])
                 {
                  int val = int(GlobalVariableGet(gvn + objname[4]) + 1);
                  val = val > 1 ? 0 : val;
                  GlobalVariableSet(gvn + objname[4], val);

                  if(val == 0)
                     ObjectsDeleteAll(0, "_Imb");
                  else
                    {
                     ChartRedraw();
                     CreateZone(int(GlobalVariableGet(gvn + objname[0])), val);
                    }

                  color warna;
                  string Font, txt;
                  CekOnOff(4, warna, txt, Font);
                  lblImb1.Color(warna);
                  lblImb2.Color(warna);
                  lblImb2.Text(txt);
                  lblImb2.Font(Font);
                 }
               else
                  if(sparam == objname[6] || sparam == objname[7])
                    {
                     int val = int(GlobalVariableGet(gvn + objname[6])) + 1;
                     val = val > 9 ? 0 : val;
                     GlobalVariableSet(gvn + objname[6], val);

                     ObjectsDeleteAll(0, "_Temp");
                     ChartRedraw();

                     if(val != 0)
                        CreateTemp(val);

                     color warna;
                     string Font, txt;
                     int FontSize;
                     CekOnTemp(warna, txt, Font, FontSize);
                     lblTemp1.Color(warna);
                     lblTemp2.Color(warna);
                     lblTemp2.Text(txt);
                     lblTemp2.Font(Font);
                     lblTemp2.FontSize(FontSize);

                    }
     }
   ChartRedraw(0);
  }
int totalZone, totalZoneBuy, totalZoneSell;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateZone(int valOB, int valImb)
  {
   int maxBar = MathMin(CalculatedBars, iBars(_Symbol, PERIOD_CURRENT));

   datetime time[];
   double open[];
   double high[];
   double low[];
   double close[];
   double fractDn[];
   double fractUp[];

   ArrayInitialize(BufferSupplyDn, 0);
   ArrayInitialize(BufferSupplyUp, 0);
   ArrayInitialize(BufferDemandUp, 0);
   ArrayInitialize(BufferDemandDn, 0);
   ArrayInitialize(CopyBufferSupply, EMPTY_VALUE);
   ArrayInitialize(CopyBufferDemand, EMPTY_VALUE);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(fractDn, true);
   ArraySetAsSeries(fractUp, true);

   CopyTime(_Symbol, PERIOD_CURRENT, 0, maxBar, time);
   CopyOpen(_Symbol, PERIOD_CURRENT, 0, maxBar, open);
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, maxBar, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, maxBar, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, maxBar, close);

   int prev_bull = 0,
       prev_bear = 0,
       index_sell = 0,
       index_buy = 0,
       imb_sell = 0,
       imb_buy = 0,
       pre_shift_bull = 0,
       pre_shift_bear = 0;

   double _lowest = 0,
          _highest = 0;

   totalZone = totalZoneBuy = totalZoneSell = 0;

   for(int x = 0; x < maxBar; x++)//Find BoS Lower
     {
      CopyBuffer(HndFractalOB, 1, x, 1, fractDn);
      CopyBuffer(HndFractalOB, 0, x, 1, fractUp);

      int bull = 0,
          bear = 0;
      //----------------------------------------------------------------------------------- Bearish Block
      if(fractDn[0] != EMPTY_VALUE && fractDn[0] != 0)//BoS lower found
        {
         int shift_lowest = 0;
         ENUM_SERIESMODE _mode = MODE_LOW;

         if(!_brokenby)
            _mode = MODE_CLOSE;

         shift_lowest = x != 0 ? iLowest(_Symbol, PERIOD_CURRENT, _mode, x - pre_shift_bear, pre_shift_bear) : 0;
         double lowest = _brokenby ? low[shift_lowest] : close[shift_lowest];

         if(lowest < fractDn[0])//BoS broken
           {
            int ind_break = 0;
            for(int i = x - 1; i > pre_shift_bear; i--)//Find candle break BoS
              {
               ind_break = i;
               double _low = _brokenby ? low[i] : close[i];
               if(_low < fractDn[0])
                  break;
               bull = open[i] < close[i] ? i : bull;
              }

            if(MathMin(low[bull], fractDn[0]) > high[iLowest(_Symbol, PERIOD_CURRENT, MODE_HIGH, ind_break, 1)])
               if(open[ind_break] >= close[ind_break])
                  if(bull > 0 && prev_bull != bull)
                    {
                     int shift_highest = 0;
                     shift_highest = ind_break - 1 != 0 ? iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, ind_break - 1, 0) : 0;
                     double highest =  high[shift_highest] ;

                     datetime time2 = time[0] + PeriodSeconds();

                     if(highest > high[bull])

                        for(int i = ind_break - 1; i >= 0; i--)
                          {
                           time2 = time[i];
                           double _high =  high[i] ;
                           if(_high > high[bull])
                              break;
                          }

                     if(highest <= high[bull] || ShowBrokenZone)
                       {

                        if(time2 > iTime(_Symbol, PERIOD_CURRENT, 0))
                          {
                           Buffer0[bull] = BufferSupplyDn[index_sell] = low[bull];
                           Buffer1[bull] = BufferSupplyUp[index_sell] = high[bull];
                           CopyBufferSupply[index_sell] = bull;
                           index_sell++;
                          }

                        if(valOB != 0)
                          {
                           CreateRectangle("OBdn" + string(time[bull]), high[bull], low[bull], time[bull], time2, SolidZoneOB, ColorBearishOB);
                           CreateTrendLine("BOSdn" + string(time[bull]), low[x], time[x], time[ind_break] + PeriodSeconds(), ColorBearishBoS);
                          }

                        prev_bull = bull;
                        pre_shift_bear = x;
                       }
                    }
           }
        }

      //----------------------------------------------------------------------------------- Bullish Block
      if(fractUp[0] != EMPTY_VALUE && fractUp[0] != 0)//BoS upper found
        {
         int shift_highest = 0;
         ENUM_SERIESMODE _mode = MODE_HIGH;

         if(!_brokenby)
            _mode = MODE_CLOSE;

         shift_highest = x != 0 ? iHighest(_Symbol, PERIOD_CURRENT, _mode, x - pre_shift_bull, pre_shift_bull) : 0;
         double highest = _brokenby ? high[shift_highest] : close[shift_highest];

         if(highest > fractUp[0])//BoS broken
           {
            int ind_break = 0;
            for(int i = x - 1; i > pre_shift_bull; i--)//Find candle break BoS
              {
               ind_break = i;
               double _high = _brokenby ? high[i] : close[i];
               if(_high > fractUp[0])
                  break;
               bear = open[i] > close[i] ? i : bear;
              }


            if(MathMax(fractUp[0], high[bear]) < low[iHighest(_Symbol, PERIOD_CURRENT, MODE_LOW, ind_break, 1)])
               if(open[ind_break] <= close[ind_break])
                  if(bear > 0 && prev_bear != bear)
                    {
                     int shift_lowest = 0;
                     shift_lowest = ind_break - 1 != 0 ? iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, ind_break - 1, 0) : 0;
                     double lowest =  low[shift_lowest] ;

                     datetime time2 = time[0] + PeriodSeconds();

                     if(lowest < low[bear])
                        for(int i = ind_break - 1; i >= 0; i--)
                          {
                           time2 = time[i];
                           double _low =  low[i] ;
                           if(_low < low[bear])
                              break;
                          }
                     if(lowest >= low[bear] || ShowBrokenZone)
                       {
                        if(time2 > iTime(_Symbol, PERIOD_CURRENT, 0))
                          {
                           Buffer2[bear] = BufferDemandUp[index_buy] = high[bear];
                           Buffer3[bear] = BufferDemandDn[index_buy] = low[bear];
                           CopyBufferDemand[index_buy] = bear;
                           index_buy++;

                          }
                        if(valOB != 0)
                          {
                           CreateRectangle("OBup" + string(time[bear]), low[bear], high[bear], time[bear], time2, SolidZoneOB, ColorBullishOB);
                           CreateTrendLine("BOSup" + string(time[bear]), high[x], time[x], time[ind_break] + PeriodSeconds(), ColorBullishBoS);
                          }
                        prev_bear = bear;
                        pre_shift_bull = x;
                       }
                    }
           }
        }

      if(valImb != 0 && x < maxBar - 1 && x > 0)
        {
         _lowest = _lowest == 0 ? low[x - 1] : _lowest > low[x - 1] ? low[x - 1] : _lowest;
         _highest = _highest == 0 ? high[x - 1] : _highest < high[x - 1] ? high[x - 1] : _highest;

         if(low[x + 1] > high[x - 1] && _highest < low[x + 1])
           {
            double price1, price2;
            datetime time1, time2;

            price1 = low[x + 1];
            price2 = MathMax(_highest, high[x - 1]);
            time1 = time[x];
            time2 = time[0] + PeriodSeconds();
            if(valImb != 0)
               CreateRectangle("_Imb" + string(time[x]), price1, price2, time1, time2, SolidZoneImb, ColorBearishImb);

            BufferImbSupplyDn[imb_sell] = price2;
            BufferImbSupplyUp[imb_sell] = price1;
            imb_sell++;
           }

         if(high[x + 1] < low[x - 1] && _lowest > high[x + 1])
           {
            double price1, price2;
            datetime time1, time2;

            price1 = high[x + 1];
            price2 = MathMin(_lowest, low[x - 1]);
            time1 = time[x];
            time2 = time[0] + PeriodSeconds();
            if(valImb != 0)
               CreateRectangle("_Imb" + string(time[x]), price1, price2, time1, time2, SolidZoneImb, ColorBullishImb);

            BufferImbDemandDn[imb_buy] = price1;
            BufferImbDemandUp[imb_buy] = price2;
            imb_buy++;
           }
        }
     }


   int maxbar = MathMax(ArraySize(CopyBufferDemand), ArraySize(CopyBufferSupply));

   for(int x = 0; x < maxbar; x++)
     {
      int cnts = CopyBufferSupply[x];
      if(cnts >= 0 && cnts != EMPTY_VALUE)
        {
         BufferSupplyDn[x] = Buffer0[cnts];
         BufferSupplyUp[x] = Buffer1[cnts];
         totalZoneSell++;
        }

      int cntd = CopyBufferDemand[x];
      if(cntd >= 0 && cntd != EMPTY_VALUE)
        {
         BufferDemandDn[x] = Buffer3[cntd];
         BufferDemandUp[x] = Buffer2[cntd];
         totalZoneBuy++;
        }

      if((cnts == EMPTY_VALUE && cntd == EMPTY_VALUE) || (cnts < 0 && cntd < 0))
         break;
     }
   totalZone = (int)MathMax(totalZoneBuy, totalZoneSell);
  }
//+------------------------------------------------------------------+
void CreateTemp(int valTemp)
  {
   ENUM_TIMEFRAMES TIMEFRAMES = PERIOD_CURRENT;

   if(valTemp == 0)
      return;
   else
     {
      switch(valTemp)
        {
         case 1:
            TIMEFRAMES = PERIOD_M1;
            break;
         case 2:
            TIMEFRAMES = PERIOD_M5;
            break;
         case 3:
            TIMEFRAMES = PERIOD_M15;
            break;
         case 4:
            TIMEFRAMES = PERIOD_M30;
            break;
         case 5:
            TIMEFRAMES = PERIOD_H1;
            break;
         case 6:
            TIMEFRAMES = PERIOD_H4;
            break;
         case 7:
            TIMEFRAMES = PERIOD_D1;
            break;
         case 8:
            TIMEFRAMES = PERIOD_W1;
            break;
         case 9:
            TIMEFRAMES = PERIOD_MN1;
            break;
        }
     }

   int maxBar = MathMin(CalculatedBars, iBars(_Symbol, TIMEFRAMES) - 1);

   datetime time[];
   double open[];
   double high[];
   double low[];
   double close[];
   double fractUp[];
   double fractDn[];

   ArrayResize(fractDn, maxBar);
   ArrayResize(fractUp, maxBar);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(fractUp, true);
   ArraySetAsSeries(fractDn, true);

   ArrayFill(BufferTempDemandDn, 0, Bars(_Symbol, PERIOD_CURRENT), 0);
   ArrayFill(BufferTempDemandUp, 0, Bars(_Symbol, PERIOD_CURRENT), 0);
   ArrayFill(BufferTempSupplyDn, 0, Bars(_Symbol, PERIOD_CURRENT), 0);
   ArrayFill(BufferTempSupplyUp, 0, Bars(_Symbol, PERIOD_CURRENT), 0);

   CopyTime(_Symbol, TIMEFRAMES, 0, maxBar, time);
   CopyOpen(_Symbol, TIMEFRAMES, 0, maxBar, open);
   CopyHigh(_Symbol, TIMEFRAMES, 0, maxBar, high);
   CopyLow(_Symbol, TIMEFRAMES, 0, maxBar, low);
   CopyClose(_Symbol, TIMEFRAMES, 0, maxBar, close);

   int prev_bull = 0,
       prev_bear = 0,
       index_sell = 0,
       index_buy = 0,
       pre_shift_bull = 0,
       pre_shift_bear = 0;

   double _lowest = 0,
          _highest = 0;

   for(int x = 2; x < maxBar - 2; x++) //Find BoS Lower
     {
      if(valTemp != 0)
        {
         int bull = 0,
             bear = 0;
         fractDn[x] = low[x] <= low[x - 1] && low[x] < low[x - 2] && low[x] <= low[x + 1] && low[x] < low[x + 2] ? low[x] : 0;
         fractUp[x] = high[x] >= high[x - 1] && high[x] > high[x - 2] && high[x] >= high[x + 1] && high[x] > high[x + 2] ? high[x] : 0;
         //----------------------------------------------------------------------------------- Bearish Block
         if(fractDn[x] != EMPTY_VALUE && fractDn[x] != 0)//BoS lower found
           {
            int shift_lowest = 0;
            ENUM_SERIESMODE _mode = MODE_LOW;

            if(!_brokenby)
               _mode = MODE_CLOSE;

            shift_lowest = x != 0 ? iLowest(_Symbol, TIMEFRAMES, _mode, x - pre_shift_bear, pre_shift_bear) : 0;
            double lowest = _brokenby ? low[shift_lowest] : close[shift_lowest];

            if(lowest < fractDn[x])//BoS broken
              {
               int ind_break = 0;
               for(int i = x - 1; i > pre_shift_bear; i--)//Find candle break BoS
                 {
                  ind_break = i;
                  double _low = _brokenby ? low[i] : close[i];
                  if(_low < fractDn[x])
                     break;
                  bull = open[i] < close[i] ? i : bull;
                 }

               //if(ObjectFind(0, "OBdn" + string(time[bull])) != 0)//No other candle break BoS created
               if(MathMin(low[bull], fractDn[x]) > high[iLowest(_Symbol, TIMEFRAMES, MODE_HIGH, ind_break, 1)])
                  if(open[ind_break] >= close[ind_break])
                     if(bull > 0 && prev_bull != bull)
                       {
                        int shift_highest = 0;
                        shift_highest = ind_break - 1 != 0 ? iHighest(_Symbol, TIMEFRAMES, MODE_HIGH, ind_break - 1, 0) : 0;
                        double highest =  high[shift_highest] ;

                        datetime time2 = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds();

                        if(highest > high[bull])
                           for(int i = ind_break - 1; i >= 0; i--)
                             {
                              time2 = time[i];
                              double _high =  high[i] ;
                              if(_high > high[bull])
                                 break;
                             }
                        if(highest <= high[bull] || ShowBrokenZone)
                          {
                           if(time2 > iTime(_Symbol, PERIOD_CURRENT, 0))
                             {
                              BufferTempSupplyDn[index_sell] = low[bull];
                              BufferTempSupplyUp[index_sell] = high[bull];
                              index_sell++;
                             }

                           CreateRectangle("_Tempdn" + string(time[bull]), high[bull], low[bull], time[bull], time2, SolidZoneTemp, ColorBearishTemp);
                           prev_bull = bull;
                           pre_shift_bear = x;
                          }
                       }
              }
           }
         //----------------------------------------------------------------------------------- Bullish Block
         if(fractUp[x] != EMPTY_VALUE && fractUp[x] != 0)//BoS upper found
           {
            int shift_highest = 0;
            ENUM_SERIESMODE _mode = MODE_HIGH;

            if(!_brokenby)
               _mode = MODE_CLOSE;

            shift_highest = x != 0 ? iHighest(_Symbol, TIMEFRAMES, _mode, x - pre_shift_bull, pre_shift_bull) : 0;

            double highest = _brokenby ? high[shift_highest] : close[shift_highest];

            if(highest > fractUp[x])//BoS broken
              {
               int ind_break = 0;
               for(int i = x - 1; i > pre_shift_bull; i--)//Find candle break BoS
                 {
                  ind_break = i;
                  double _high = _brokenby ? high[i] : close[i];
                  if(_high > fractUp[x])
                     break;
                  bear = open[i] > close[i] ? i : bear;
                 }

               //if(ObjectFind(0, "OBup" + string(time[bear])) != 0)//No other candle break BoS created
               if(MathMax(high[bear], fractUp[x]) < low[iHighest(_Symbol, TIMEFRAMES, MODE_LOW, ind_break, 1)])
                  if(open[ind_break] <= close[ind_break])
                     if(bear > 0 && prev_bear != bear)
                       {
                        int shift_lowest = 0;
                        shift_lowest = ind_break - 1 != 0 ? iLowest(_Symbol, TIMEFRAMES, MODE_LOW, ind_break - 1, 0) : 0;
                        double lowest =  low[shift_lowest] ;

                        datetime time2 = iTime(_Symbol, PERIOD_CURRENT, 0) + PeriodSeconds();

                        if(lowest < low[bear])
                           for(int i = ind_break - 1; i >= 0; i--)
                             {
                              time2 = time[i];
                              double _low =  low[i] ;
                              if(_low < low[bear])
                                 break;
                             }
                        if(lowest >= low[bear] || ShowBrokenZone)
                          {
                           if(time2 > time[0])
                             {
                              BufferTempDemandDn[index_buy] = low[bear];
                              BufferTempDemandUp[index_buy] = high[bear];
                              index_buy++;
                             }
                           CreateRectangle("_Tempup" + string(time[bear]), low[bear], high[bear], time[bear], time2, SolidZoneTemp, ColorBullishTemp);
                           prev_bear = bear;
                           pre_shift_bull = x;
                          }
                       }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateRR(int val, int _valRR)
  {
   if(_valRR == 0)
      return;
   else
      _valRR = _valRR - 1;

   if(val == 3 || val == 2)
      if(BufferSupplyDn[_valRR] > 0 && BufferSupplyUp[_valRR] > 0
         && BufferSupplyDn[_valRR] != EMPTY_VALUE && BufferSupplyUp[_valRR] != EMPTY_VALUE)
        {
         CreateFibo("_FiboDn", BufferSupplyDn[_valRR], BufferSupplyUp[_valRR]);
        }
   if(val == 3 || val == 1)
      if(BufferDemandUp[_valRR] > 0 && BufferDemandDn[_valRR] > 0
         && BufferDemandUp[_valRR] != EMPTY_VALUE && BufferDemandDn[_valRR] != EMPTY_VALUE)
        {
         CreateFibo("_FiboUp", BufferDemandUp[_valRR], BufferDemandDn[_valRR]);
        }
  }
//+------------------------------------------------------------------+
string gvn, objname[] =
  {
   "Manual Trend",
   "Trend : ",
   "Entry Level",
   "RR : ",
   "Imbalance",
   "Imbalance : ",
   "Temp",
   "Temp : "
  };
//+------------------------------------------------------------------+
void CreatePanel()
  {
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   string txt = objname[0];
   string Font = "Arial";
   color warna = clrWhite;

   CekTrend(warna, txt, Font);
   int ydist = 0;

   lblTrend1.Create(0, objname[0], 0, 40, 30, 0, 0);
   lblTrend1.Text(objname[0]);
   lblTrend1.Font("Cambria");
   lblTrend1.FontSize(11);
   lblTrend1.Color(warna);
   lblTrend1.BringToTop();

   int val = (int)GlobalVariableGet(gvn + objname[0]);
   if(val == 0)
      ydist = 28;
   else
      ydist = 25;

   lblTrend2.Create(0, objname[1], 0, 10, ydist, 0, 0);
   lblTrend2.Text(txt);
   lblTrend2.Font(Font);
   lblTrend2.FontSize(18);
   lblTrend2.Color(warna);
   lblTrend2.BringToTop();

// CekOnOff(2, warna, txt, Font);
   int x1, y1, fz;
   val = (int)GlobalVariableGet(gvn + objname[2]);
   if(val == 0)
     {
      warna = clrGray;
      txt = "O";
      Font = "Wingdings 2";
      x1 = 10;
      y1 = 53;
      fz = 18;
     }
   else
     {
      warna = clrDodgerBlue;
      txt = string(val);
      Font = "Cambria";
      x1 = 13;
      y1 = 55;
      fz = 11;
     }

   lblEntry1.Create(0, objname[2], 0, 40, 55, 0, 0);
   lblEntry1.Text(objname[2]);
   lblEntry1.FontSize(11);
   lblEntry1.Font("Cambria");
   lblEntry1.Color(warna);
   lblEntry1.BringToTop();

   lblEntry2.Create(0, objname[3], 0, x1, y1, 0, 0);
   lblEntry2.Text(txt);
   lblEntry2.FontSize(fz);
   lblEntry2.Font(Font);
   lblEntry2.Color(warna);
   lblEntry2.BringToTop();

   CekOnOff(4, warna, txt, Font);

   lblImb1.Create(0, objname[4], 0, 40, 80, 0, 0);
   lblImb1.Text(objname[4]);
   lblImb1.FontSize(11);
   lblImb1.Font("Cambria");
   lblImb1.Color(warna);
   lblImb1.BringToTop();

   lblImb2.Create(0, objname[5], 0, 10, 78, 0, 0);
   lblImb2.Text(txt);
   lblImb2.FontSize(18);
   lblImb2.Font(Font);
   lblImb2.Color(warna);
   lblImb2.BringToTop();

   int FontSize;
   CekOnTemp(warna, txt, Font, FontSize);

   lblTemp1.Create(0, objname[6], 0, 40, 105, 0, 0);
   lblTemp1.Text(objname[6]);
   lblTemp1.FontSize(11);
   lblTemp1.Font("Cambria");
   lblTemp1.Color(warna);
   lblTemp1.BringToTop();

   int xdist = 5;
   val = (int)GlobalVariableGet(gvn + objname[6]);

   if(val == 3 || val == 4 || val == 9)
     {
      ydist = 105;
      xdist = 5;
     }
   else
     {
      if(val == 0)
         ydist = 103;
      else
         ydist = 105;
      xdist = 10;
     }

   lblTemp2.Create(0, objname[7], 0, xdist, ydist, 0, 0);
   lblTemp2.Text(txt);
   lblTemp2.FontSize(FontSize);
   lblTemp2.Font(Font);
   lblTemp2.Color(warna);
   lblTemp2.BringToTop();

   for(int x = 0; x < 8; x++)
     {

      ObjectSetInteger(0, objname[x], OBJPROP_CORNER, 3);
      ObjectSetInteger(0, objname[x], OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);

     }
  }
//+------------------------------------------------------------------+
void CekTrend(color & warna, string & txt, string & Font)
  {
   int val = int(GlobalVariableGet(gvn + objname[0]));
   switch(val)
     {
      case 0:
         warna = clrGray;
         txt = "O";
         Font = "Wingdings 2";
         break;
      case 1:
         warna = C'38,166,154';
         txt = "k";
         Font = "Wingdings 3";
         break;
      case 2:
         warna = C'239,83,80';
         txt = "m";
         Font = "Wingdings 3";
         break;
      case 3:
         warna = clrDodgerBlue;
         txt = "g";
         Font = "Wingdings 3";
         break;
     }
  }
//+------------------------------------------------------------------+
void CekOnOff(int index, color & warna, string & txt, string & Font)
  {
   int val = int(GlobalVariableGet(gvn + objname[index]));
   switch(val)
     {
      case 0:
         warna = clrGray;
         txt = "O";
         Font = "Wingdings 2";
         break;
      case 1:
         warna = clrDodgerBlue;
         txt = "P";
         Font = "Wingdings 2";
         break;
     }
  }
//+------------------------------------------------------------------+
void CekOnTemp(color &warna, string &txt, string &Font, int&FontSize)
  {
   int val = int(GlobalVariableGet(gvn + objname[6]));
   warna = clrDodgerBlue;
   Font = "Cambria";
   FontSize = 11;
   if(val == 0)
     {
      warna = clrGray;
      txt = "O";
      Font = "Wingdings 2";
      FontSize = 18;
     }
   else
      txt = PoiToString(val);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PoiToString(int val)
  {
   string txt = "";
   switch(val)
     {
      case 1:
         txt = "M1";
         break;
      case 2:
         txt = "M5";
         break;
      case 3:
         txt = "M15";
         break;
      case 4:
         txt = "M30";
         break;
      case 5:
         txt = "H1";
         break;
      case 6:
         txt = "H4";
         break;
      case 7:
         txt = "D1";
         break;
      case 8:
         txt = "W1";
         break;
      case 9:
         txt = "MN1";
         break;
     }
   return txt;
  }
//+------------------------------------------------------------------+
bool CreateTrendLine(string obj_name,
                     double price1,
                     datetime time1,
                     datetime time2,
                     color Color = clrBlack)
  {
   bool res = false;
   if(ObjectFind(0, obj_name) != 0)
     {
      ObjectCreate(0, obj_name, OBJ_TREND, 0, 0, 0);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, Color);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, WidthLineBoS);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, LineStyleBoS);
      ObjectSetInteger(0, obj_name, OBJPROP_RAY, false);
      ObjectCreate(0, obj_name + "txt", OBJ_TEXT, 0, 0, 0);
      ObjectSetString(0, obj_name + "txt", OBJPROP_TEXT, "BoS");
      ENUM_ANCHOR_POINT anchor = StringFind(obj_name, "dn") >= 0 ? ANCHOR_RIGHT_UPPER : ANCHOR_RIGHT_LOWER;
      ObjectSetInteger(0, obj_name + "txt", OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, obj_name + "txt", OBJPROP_COLOR, Color);
      res = true;
     }
   ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, price1);
   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 0, time1);
   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time2);
   ObjectSetDouble(0, obj_name + "txt", OBJPROP_PRICE, price1);
   ObjectSetInteger(0, obj_name + "txt", OBJPROP_TIME, time2 - 2 * PeriodSeconds());
   return res;
  }
//+------------------------------------------------------------------+
bool CreateRectangle(string obj_name,
                     double price1,
                     double price2,
                     datetime time1,
                     datetime time2,
                     bool fill = true,
                     color Color = clrBlack)
  {
   bool res = false;
   if(ObjectFind(0, obj_name) != 0)
     {
      ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, 0, 0);
      ObjectSetInteger(0, obj_name, OBJPROP_FILL, fill);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, Color);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, WidthLineBoS);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, LineStyleBoS);
      if(time2 > iTime(_Symbol, PERIOD_CURRENT, 0) && StringFind(obj_name, "_Imb") != 0)
        {
         ENUM_OBJECT tipe = StringFind(obj_name, "Temp") >= 0 ? OBJ_ARROW_LEFT_PRICE : OBJ_ARROW_RIGHT_PRICE;
         ObjectCreate(0, obj_name + "pUp", tipe, 0, 0, 0);
         ObjectCreate(0, obj_name + "pDn", tipe, 0, 0, 0);
         ObjectSetInteger(0, obj_name + "pUp", OBJPROP_BACK, true);
         ObjectSetInteger(0, obj_name + "pDn", OBJPROP_BACK, true);
        }
      res = true;
     }
   ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, price2);
   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 0, time1);
   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time2);

   ObjectSetDouble(0, obj_name + "pUp", OBJPROP_PRICE, price1);
   ObjectSetDouble(0, obj_name + "pDn", OBJPROP_PRICE, price2);
   ObjectSetInteger(0, obj_name + "pUp", OBJPROP_TIME, time2);
   ObjectSetInteger(0, obj_name + "pDn", OBJPROP_TIME, time2);
   ObjectSetInteger(0, obj_name + "pUp", OBJPROP_COLOR, Color);
   ObjectSetInteger(0, obj_name + "pDn", OBJPROP_COLOR, Color);
   if(StringFind(obj_name, "Temp") >= 0)
     {
      ObjectSetInteger(0, obj_name + "pUp", OBJPROP_BACK, false);
      ObjectSetInteger(0, obj_name + "pDn", OBJPROP_BACK, false);
     }
   return res;
  }
//+------------------------------------------------------------------+
string TimeframesToString(int tf)
  {
   string _tf = "";
   switch(tf)
     {
      case PERIOD_M1:
         _tf = "M1";
         break;
      case PERIOD_M5:
         _tf = "M5";
         break;
      case PERIOD_M10:
         _tf = "M10";
         break;
      case PERIOD_M15:
         _tf = "M15";
         break;
      case PERIOD_M20:
         _tf = "M20";
         break;
      case PERIOD_M30:
         _tf = "M30";
         break;
      case PERIOD_H1:
         _tf = "H1";
         break;
      case PERIOD_H4:
         _tf = "H4";
         break;
      case PERIOD_H8:
         _tf = "H8";
         break;
      case PERIOD_H12:
         _tf = "H12";
         break;
      case PERIOD_D1:
         _tf = "D1";
         break;
      case PERIOD_W1:
         _tf = "W1";
         break;
      case PERIOD_MN1:
         _tf = "MN1";
         break;
     }
   return _tf;
  }
string desc[12] = {"Entry", "Stop", "1 RR", "2 RR", "3 RR", "4 RR", "5 RR", "6 RR", "7 RR", "8 RR", "9 RR", "10 RR"};
//+------------------------------------------------------------------+
void CreateFibo(string obj_name, double price1, double price2)
  {
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   datetime time2 = time;// + PeriodSeconds() * 5;
   double _price1 = (double)ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0),
          _price2 = (double)ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);

   if(_price1 != price1 || _price2 != price2)
     {
      if(obj_name == "_FiboUp")
        {
         fiboUp.Delete();
         fiboUp.Create(0, obj_name, 0, time, price1, time2, price2);
         ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, false);

         fiboUp.LevelsCount(12);
         fiboUp.RayRight(true);

         for(int i = 0; i < 12; i++)
           {
            fiboUp.LevelColor(i, ColorEntryLevelUp);
            ObjectSetInteger(0, obj_name, OBJPROP_LEVELSTYLE, i, STYLE_DOT);
            fiboUp.LevelValue(i, _level[i]);
            fiboUp.LevelDescription(i, desc[i]);
           }
        }
      else
         if(obj_name == "_FiboDn")
           {
            fiboDn.Delete();
            fiboDn.Create(0, obj_name, 0, time, price1, time2, price2);

            fiboDn.LevelsCount(12);
            fiboDn.RayRight(true);

            for(int i = 0; i < 12; i++)
              {
               fiboDn.LevelColor(i, ColorEntryLevelDn);
               ObjectSetInteger(0, obj_name, OBJPROP_LEVELSTYLE, i, STYLE_DOT);
               fiboDn.LevelValue(i, _level[i]);
               fiboDn.LevelDescription(i, desc[i]);
              }
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveFibo(int tipe)
  {
   string obj_name = tipe == -1 ? "_Fibo" : tipe == 0 ? "_FiboUp" : "_FiboDn";
   ObjectsDeleteAll(0, obj_name);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void _copybuffer()
  {
   ENUM_TIMEFRAMES _TF[9] =
     {
      PERIOD_M1,
      PERIOD_M5,
      PERIOD_M15,
      PERIOD_M30,
      PERIOD_H1,
      PERIOD_H4,
      PERIOD_D1,
      PERIOD_W1,
      PERIOD_MN1
     };
   for(int x = 0; x < 9; x++)
     {
      CopyTime(_Symbol, _TF[x], 0, CalculatedBars, _time_);
      CopyOpen(_Symbol, _TF[x], 0, CalculatedBars, _open_);
      CopyHigh(_Symbol, _TF[x], 0, CalculatedBars, _high_);
      CopyLow(_Symbol, _TF[x], 0, CalculatedBars, _low_);
      CopyClose(_Symbol, _TF[x], 0, CalculatedBars, _close_);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool checkAccountNumber(long number)
  {
   return number == AccountInfoInteger(ACCOUNT_LOGIN);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|Fibo for do Buy                                                   |
//+------------------------------------------------------------------+
double Fibo_Buy(int Number_Candle_Max, int Number_Candle_Low, double Value_Fibo)
  {
   double Result, Part_100_Fibo;

//Maximum value Between candles
   double Value_Max=iHigh(_Symbol,Temporalidad,Number_Candle_Max);

//Manimun valueBetween candles
   double Value_Min=iLow(_Symbol,Temporalidad,Number_Candle_Low);

//Determine the Fibo
   Part_100_Fibo=(Value_Max-Value_Min)/100; // Part 100 of Fibonacci
   Result=Value_Max-(Value_Fibo*Part_100_Fibo);

   return Result;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Fibo for do Sell                                                  |
//+------------------------------------------------------------------+
double Fibo_Sell(int Number_Candle_Max, int Number_Candle_Low, double Value_Fibo)
  {
   double Result, Part_100_Fibo;

//Maximum value Between candles
   double Value_Max=iHigh(_Symbol,Temporalidad,Number_Candle_Max);

//Manimun value Between candles
   double Value_Min=iLow(_Symbol,Temporalidad,Number_Candle_Low);

//Determine the Fibo
   Part_100_Fibo=(Value_Max-Value_Min)/100; // Part 100 of Fibonacci
   Result=Value_Min+(Value_Fibo*Part_100_Fibo);

   return Result;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Gartley Sell                                              |
//+------------------------------------------------------------------+
double Pattern_Gartley_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point A)
      CopyLow(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMinimum(Point_A,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMaximum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].low;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_A_Now>Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point B) and Point C (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyLow(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMinimum(Point_C,0,Final);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }

            //Determine the A1 (for Point B)
            double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Gartley_Min);
            double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Gartley_Max);

            //Determine the A3 (for Point C)
            double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboXA_B_Gartley_Max);
            double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboXA_B_Gartley_Max);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].high;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,(FiboXA_D_Gartley-Fibo_Point)) && Current_Price>=Value_Point_B)
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }
            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         //Validation of Extrem Point in C
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)

         //Determine the low Candle Between B and C, include B and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMinimum(Comparice_C,0,Number_Candle_Point_B);
         double Comparice_C_Point=Price_Information[Number_Comparice_C].low;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].low;

         //Compare Abvove Value with C, ans if above vulue is lower, Pattern_Arm is false
         if(Comparice_C_Point<Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)

         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;

         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Gartley);

         if(Comparice_D_Point>Value_Point_D)
           {
            Pattern_Arm=false;
           }

        }
      //+------------------------------------------------------------------+
      //|Paint Pattern                                                      |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Gartley);
         double Value_Point_D1=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Gartley+2.2);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Gartley_Sell");
         ObjectDelete(0,"Triangle B-C-D_Gartley_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Gartley_Sell",                        //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Gartley_Sell",OBJPROP_COLOR,clrDarkGoldenrod);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Gartley_Sell",                        //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );
         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Gartley_Sell",OBJPROP_COLOR,clrDarkGoldenrod);
         ObjectDelete(0,"Gartley_Sell");
         ObjectDelete(0,"Gartley_Sell_Ray");
         ObjectDelete(0,"Gartley_Sell_Text");

         //Flecha
         ObjectCreate(0,"Gartley_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D1);
         ObjectSetInteger(0,"Gartley_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Gartley_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Gartley_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Gartley_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Gartley_Sell_Text",OBJPROP_COLOR,clrDarkGoldenrod);
         ObjectSetString(0,"Gartley_Sell_Text",OBJPROP_TEXT,"-Gartley");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Gartley_Sell");
         ObjectDelete(0,"Gartley_Sell_Ray");
         ObjectDelete(0,"Gartley_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Gartley_Sell");
         ObjectDelete(0,"Triangle B-C-D_Gartley_Sell");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Gartley Buy                                               |
//+------------------------------------------------------------------+
double Pattern_Gartley_Buy()
  {

   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point A)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMaximum(Point_A,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMinimum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].high;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_A_Now<Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyHigh(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMaximum(Point_C,0,Final);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }

            //Determine the A1 (for Point B)
            double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Gartley_Min);
            double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Gartley_Max);

            //Determine the A3 (for Point C)
            double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Gartley_Max);
            double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Gartley_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].low;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].high;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price<=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,(FiboXA_D_Gartley-Fibo_Point)) && Current_Price<=Value_Point_B)
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }

            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)
         //Determine the High Candle Between B and C, cinclude B and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMaximum(Comparice_C,0,Number_Candle_Point_B);
         double Comparico_C_Point=Price_Information[Number_Comparice_C].high;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].high;

         //Compare Abvove Value with C, ans if above vulue is Biger, Pattern_Arm is false
         if(Comparico_C_Point>Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;

         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Gartley);

         if(Comparice_D_Point<Value_Point_D)
           {
            Pattern_Arm=false;
           }
        }
      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Gartley);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Gartley_Buy");
         ObjectDelete(0,"Triangle B-C-D_Gartley_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Gartley_Buy",                    //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Gartley_Buy",OBJPROP_COLOR,clrDarkGoldenrod);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Gartley_Buy",                    //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Gartley_Buy",OBJPROP_COLOR,clrDarkGoldenrod);
         ObjectDelete(0,"Bat_Buy");
         ObjectDelete(0,"Bat_Buy_Ray");
         ObjectDelete(0,"Bat_Buy_Text");

         //Flecha
         ObjectCreate(0,"Gartley_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Gartley_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Gartley_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Gartley_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Gartley_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Gartley_Buy_Text",OBJPROP_COLOR,clrDarkGoldenrod);
         ObjectSetString(0,"Gartley_Buy_Text",OBJPROP_TEXT,"-Gartley");

        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Gartley_Buy");
         ObjectDelete(0,"Gartley_Buy_Ray");
         ObjectDelete(0,"Gartley_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Gartley_Buy");
         ObjectDelete(0,"Triangle B-C-D_Gartley_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Bat Sell                                                  |
//+------------------------------------------------------------------+
double Pattern_Bat_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point A)
      CopyLow(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMinimum(Point_A,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMaximum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].low;
      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_A_Now>Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point B) and Point C (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyLow(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMinimum(Point_C,0,Final);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }


            //Determine the A1 (for Point B)
            double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_BAT_Min);
            double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_BAT_Max);

            //Determine the A3 (for Point C)
            double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_BAT_Max);
            double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_BAT_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].high;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,(FiboXA_D_BAT-Fibo_Point)) && Current_Price>=Value_Point_B)
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }
            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         //Validation of Extrem Point in C
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)

         //Determine the low Candle Between B and C, include B and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMinimum(Comparice_C,0,Number_Candle_Point_B);
         double Comparice_C_Point=Price_Information[Number_Comparice_C].low;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].low;

         //Compare Abvove Value with C, ans if above vulue is lower, Pattern_Arm is false
         if(Comparice_C_Point<Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)

         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;

         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_BAT);

         if(Comparice_D_Point>Value_Point_D)
           {
            Pattern_Arm=false;
           }

        }
      //+------------------------------------------------------------------+
      //|Paint Pattern                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_BAT);
         double Value_Point_D1=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_BAT+2.2);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Bat_Sell");
         ObjectDelete(0,"Triangle B-C-D_Bat_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Bat_Sell",                       //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Bat_Sell",OBJPROP_COLOR,clrBlue);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Bat_Sell",                       //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Bat_Sell",OBJPROP_COLOR,clrBlue);
         ObjectDelete(0,"Bat_Sell");
         ObjectDelete(0,"Bat_Sell_Ray");
         ObjectDelete(0,"Bat_Sell_Text");

         //Flecha
         ObjectCreate(0,"Bat_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D1);
         ObjectSetInteger(0,"Bat_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Bat_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Bat_Sell_Ray",OBJPROP_COLOR,clrRed);


         //Text
         ObjectCreate(0,"Bat_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Bat_Sell_Text",OBJPROP_COLOR,clrBlue);
         ObjectSetString(0,"Bat_Sell_Text",OBJPROP_TEXT,"            -Bat");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Bat_Sell");
         ObjectDelete(0,"Bat_Sell_Ray");
         ObjectDelete(0,"Bat_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Bat_Sell");
         ObjectDelete(0,"Triangle B-C-D_Bat_Sell");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Bat Buy                                                   |
//+------------------------------------------------------------------+
double Pattern_Bat_Buy()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point A)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMaximum(Point_A,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMinimum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].high;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_A_Now<Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyHigh(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMaximum(Point_C,0,Final);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }


            //Determine the A1 (for Point B)
            double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_BAT_Min);
            double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_BAT_Max);

            //Determine the A3 (for Point C)
            double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_BAT_Max);
            double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_BAT_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].low;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].high;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price<=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,(FiboXA_D_BAT-Fibo_Point)) && Current_Price<=Value_Point_B)
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }

            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)
         //Determine the High Candle Between B and C, cinclude B and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMaximum(Comparice_C,0,Number_Candle_Point_B);
         double Comparico_C_Point=Price_Information[Number_Comparice_C].high;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].high;

         //Compare Abvove Value with C, ans if above vulue is Biger, Pattern_Arm is false
         if(Comparico_C_Point>Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;

         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_BAT);

         if(Comparice_D_Point<Value_Point_D)
           {
            Pattern_Arm=false;
           }
        }
      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_BAT);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Bat_Buy");
         ObjectDelete(0,"Triangle B-C-D_Bat_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Bat_Buy",                        //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,    //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,   //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low     //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Bat_Buy",OBJPROP_COLOR,clrBlue);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Bat_Buy",                        //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,    //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                    //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Bat_Buy",OBJPROP_COLOR,clrBlue);
         ObjectDelete(0,"Bat_Buy");
         ObjectDelete(0,"Bat_Buy_Ray");
         ObjectDelete(0,"Bat_Buy_Text");

         //Flecha
         ObjectCreate(0,"Bat_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Bat_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Bat_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Bat_Buy_Ray",OBJPROP_COLOR,clrGreen);


         //Text
         ObjectCreate(0,"Bat_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Bat_Buy_Text",OBJPROP_COLOR,clrBlue);
         ObjectSetString(0,"Bat_Buy_Text",OBJPROP_TEXT,"            -Bat");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Bat_Buy");
         ObjectDelete(0,"Bat_Buy_Ray");
         ObjectDelete(0,"Bat_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Bat_Buy");
         ObjectDelete(0,"Triangle B-C-D_Bat_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Butterfly Sell                                            |
//+------------------------------------------------------------------+
double Pattern_Butterfly_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point A)
      CopyLow(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMinimum(Point_A,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMaximum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].low;
      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_A_Now>Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point B) and Point C (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         bool Point_CC=false;
         bool Point_DD=false;
         Pattern_Arm=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyLow(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMinimum(Point_C,0,Final);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }


            //Determine the A1 (for Point B)
            double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Butterfly_Min);
            double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Butterfly_Max);

            //Determine the A3 (for Point C)
            double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Butterfly_Max);
            double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Butterfly_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].high;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,(FiboXA_D_Butterfly-Fibo_Point)))
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }
            Final=Final-4;
            Inicial=Inicial+4;
           }

        }

      if(Pattern_Arm)
        {
         //Validation of Extrem Point in C
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)
         //Determine the low Candle Between B and C, include B and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMinimum(Comparice_C,0,Number_Candle_Point_B);
         double Comparice_C_Point=Price_Information[Number_Comparice_C].low;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
         //Compare Abvove Value with C, ans if above vulue is lower, Pattern_Arm is false
         if(Comparice_C_Point<Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Butterfly);
         if(Comparice_D_Point>Value_Point_D)
           {
            Pattern_Arm=false;
           }
        }

      //+------------------------------------------------------------------+
      //|Paint Pattern                                                      |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Butterfly);
         double Value_Point_D1=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Butterfly+2.2);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Butterfly_Sell");
         ObjectDelete(0,"Triangle B-C-D_Butterfly_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Butterfly_Sell",                 //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Butterfly_Sell",OBJPROP_COLOR,clrRed);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Butterfly_Sell",                 //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Butterfly_Sell",OBJPROP_COLOR,clrRed);
         ObjectDelete(0,"Butterfly_Sell");
         ObjectDelete(0,"Butterfly_Sell_Ray");
         ObjectDelete(0,"Butterfly_Sell_Text");

         //Flecha
         ObjectCreate(0,"Butterfly_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D1);
         ObjectSetInteger(0,"Butterfly_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Butterfly_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Butterfly_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Butterfly_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Butterfly_Sell_Text",OBJPROP_COLOR,clrRed);
         ObjectSetString(0,"Butterfly_Sell_Text",OBJPROP_TEXT,"                -Butterfly");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Butterfly_Sell");
         ObjectDelete(0,"Butterfly_Sell_Ray");
         ObjectDelete(0,"Butterfly_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Butterfly_Sell");
         ObjectDelete(0,"Triangle B-C-D_Butterfly_Sell");
        }
     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Butterfly Buy                                             |
//+------------------------------------------------------------------+
double Pattern_Butterfly_Buy()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point A)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMaximum(Point_A,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMinimum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].high;
      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_A_Now<Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyHigh(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMaximum(Point_C,0,Final);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);


            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }

            //Determine the A1 (for Point B)
            double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Butterfly_Min);
            double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Butterfly_Max);

            //Determine the A3 (for Point C)
            double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Butterfly_Max);
            double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Butterfly_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].low;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].high;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price<=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,(FiboXA_D_Butterfly-Fibo_Point)))
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }

            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)
         //Determine the High Candle Between B and C, cinclude B and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMaximum(Comparice_C,0,Number_Candle_Point_B);
         double Comparico_C_Point=Price_Information[Number_Comparice_C].high;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].high;

         //Compare Abvove Value with C, ans if above vulue is Biger, Pattern_Arm is false
         if(Comparico_C_Point>Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;

         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Butterfly);

         if(Comparice_D_Point<Value_Point_D)
           {
            Pattern_Arm=false;
           }
        }
      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Butterfly);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Butterfly_Buy");
         ObjectDelete(0,"Triangle B-C-D_Butterfly_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Butterfly_Buy",                  //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,    //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,   //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low     //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Butterfly_Buy",OBJPROP_COLOR,clrRed);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Butterfly_Buy",                  //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,    //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                    //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Butterfly_Buy",OBJPROP_COLOR,clrRed);
         ObjectDelete(0,"Butterfly_Buy");
         ObjectDelete(0,"Butterfly_Buy_Ray");
         ObjectDelete(0,"Butterfly_Buy_Text");

         //Flecha
         ObjectCreate(0,"Butterfly_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Butterfly_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Butterfly_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Butterfly_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Butterfly_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Butterfly_Buy_Text",OBJPROP_COLOR,clrRed);
         ObjectSetString(0,"Butterfly_Buy_Text",OBJPROP_TEXT,"                -Butterfly");
        }

      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Butterfly_Buy");
         ObjectDelete(0,"Butterfly_Buy_Ray");
         ObjectDelete(0,"Butterfly_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Butterfly_Buy");
         ObjectDelete(0,"Triangle B-C-D_Butterfly_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Crab Sell                                                 |
//+------------------------------------------------------------------+
double Pattern_Crab_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point A)
      CopyLow(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMinimum(Point_A,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMaximum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].low;
      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_A_Now>Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point B) and Point C (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyLow(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMinimum(Point_C,0,Final);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }

            //Determine the A1 (for Point B)
            double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Crab_Min);
            double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Crab_Max);

            //Determine the A3 (for Point C)
            double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Butterfly_Max);
            double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Butterfly_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].high;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,(FiboXA_D_Crab-Fibo_Point)))
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }

                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }

           }
        }

      if(Pattern_Arm)
        {
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Crab);
         //Validation of Extrem Point in C
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)

         //Determine the low Candle Between B and C, include B and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMinimum(Comparice_C,0,Number_Candle_Point_B);
         double Comparice_C_Point=Price_Information[Number_Comparice_C].low;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].low;

         //Compare Abvove Value with C, ans if above vulue is lower, Pattern_Arm is false
         if(Comparice_C_Point<Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)

         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;

         if(Comparice_D_Point>Value_Point_D)
           {
            Pattern_Arm=false;
           }

        }
      //+------------------------------------------------------------------+
      //|Paint Pattern                                                      |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Crab);
         double Value_Point_D1=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_D_Crab+2.2);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Crab_Sell");
         ObjectDelete(0,"Triangle B-C-D_Crab_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Crab_Sell",                      //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Crab_Sell",OBJPROP_COLOR,clrGreen);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Crab_Sell",                      //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Crab_Sell",OBJPROP_COLOR,clrGreen);
         ObjectDelete(0,"Crab_Sell");
         ObjectDelete(0,"Crab_Sell_Ray");
         ObjectDelete(0,"Crab_Sell_Text");

         //Flecha
         ObjectCreate(0,"Crab_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D1);
         ObjectSetInteger(0,"Crab_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Crab_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Crab_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Crab_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Crab_Sell_Text",OBJPROP_COLOR,clrGreen);
         ObjectSetString(0,"Crab_Sell_Text",OBJPROP_TEXT,"                             -Crab");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Crab_Sell");
         ObjectDelete(0,"Crab_Sell_Ray");
         ObjectDelete(0,"Crab_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Crab_Sell");
         ObjectDelete(0,"Triangle B-C-D_Crab_Sell");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Crab Buy                                                  |
//+------------------------------------------------------------------+
double Pattern_Crab_Buy()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point A)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_A);
      Number_Candle_Point_A=ArrayMaximum(Point_A,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_A,k-Number_Candle_Point_A,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_A+ArrayMinimum(Point_X,0,k-Number_Candle_Point_A);

      Number_Candle_Point_B=0;
      Number_Candle_Point_C=0;

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_A==k || Number_Candle_Point_A==1 || Number_Candle_Point_A==0 || Number_Candle_Point_A>Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_A_Now=Price_Information[Number_Candle_Point_A].high;
      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_A_Next=Price_Information[Number_Candle_Point_A+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_A_Now<Value_Point_A_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_CC=false;
         bool Point_DD=false;
         int Final=Number_Candle_Point_A-1;
         int Inicial=1;

         for(int i=Number_Candle_Point_A-1; i>1; i--)
           {
            CopyHigh(Symbol(),Temporalidad,0,Final,Point_C); //Determine the value Point C
            Number_Candle_Point_C=ArrayMaximum(Point_C,0,Final);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Number_Candle_Point_A-Number_Candle_Point_C,Point_B); //Determine the value Point D
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Number_Candle_Point_A-Number_Candle_Point_C);

            if(Number_Candle_Point_C<1 || Number_Candle_Point_B<1)
              {
               break;
              }

            //Determine the A1 (for Point B)
            double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Crab_Min);
            double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Crab_Max);

            //Determine the A3 (for Point C)
            double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Crab_Max);
            double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Crab_Min);

            //Validation Point B and C
            Point_DD=false;
            double Value_Point_B=Price_Information[Number_Candle_Point_B].low;
            double Value_Point_C=Price_Information[Number_Candle_Point_C].high;
            if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
              {
               if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                 {
                  if(Current_Price<=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,(FiboXA_D_Crab-Fibo_Point)))
                    {
                     Point_DD=true;
                     Pattern_Arm=true;
                    }
                 }
              }

            if(Point_DD)
              {
               break;
              }

            if(Number_Candle_Point_C<2 || Inicial>Final)
              {
               Pattern_Arm=false;
               Point_CC=false;
               break;
              }

            Final=Final-4;
            Inicial=Inicial+4;
           }
        }

      if(Pattern_Arm)
        {
         double Comparice_C[];
         ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)
         //Determine the High Candle Between B and C, cinclude B and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
         int Number_Comparice_C=ArrayMaximum(Comparice_C,0,Number_Candle_Point_B);
         double Comparico_C_Point=Price_Information[Number_Comparice_C].high;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].high;

         //Compare Abvove Value with C, ans if above vulue is Biger, Pattern_Arm is false
         if(Comparico_C_Point>Value_Point_C)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;

         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Crab);

         if(Comparice_D_Point<Value_Point_D)
           {
            Pattern_Arm=false;
           }
        }
      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {
         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_D_Crab);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Crab_Buy");
         ObjectDelete(0,"Triangle B-C-D_Crab_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Crab_Buy",                       //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,    //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,   //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low     //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Crab_Buy",OBJPROP_COLOR,clrGreen);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Crab_Buy",                       //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,    //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Crab_Buy",OBJPROP_COLOR,clrGreen);
         ObjectDelete(0,"Crab_Buy");
         ObjectDelete(0,"Crab_Buy_Ray");
         ObjectDelete(0,"Crab_Buy_Text");

         //Flecha
         ObjectCreate(0,"Crab_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Crab_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Crab_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Crab_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Crab_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Crab_Buy_Text",OBJPROP_COLOR,clrGreen);
         ObjectSetString(0,"Crab_Buy_Text",OBJPROP_TEXT,"                             -Crab");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Crab_Buy");
         ObjectDelete(0,"Crab_Buy_Ray");
         ObjectDelete(0,"Crab_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Crab_Buy");
         ObjectDelete(0,"Triangle B-C-D_Crab_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Shark Shark Sell                                                 |
//+------------------------------------------------------------------+
double Pattern_Shark_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point C)
      CopyLow(Symbol(),Temporalidad,0,k,Point_C);
      Number_Candle_Point_C=ArrayMinimum(Point_C,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C+1,k-Number_Candle_Point_C-1,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_C+1+ArrayMaximum(Point_X,0,k-Number_Candle_Point_C-1);

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_C==k || Number_Candle_Point_C==1 || Number_Candle_Point_C==0 || Number_Candle_Point_C>=Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_C_Now=Price_Information[Number_Candle_Point_C].low;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_C_Next=Price_Information[Number_Candle_Point_C+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_C_Now>Value_Point_C_Next))
           {
            Pattern_Arm=false;
           }
        }

      double Value_Point_D=0;
      double Value_Point_B=0;
      //Determine the Second High Candle (Point B) and Point A (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point A)
         Pattern_Arm=false;
         bool Point_DD=false;
         int Incio=Number_Candle_Point_C+1;
         int Final=Number_Candle_Point_X-1;

         for(int i=Number_Candle_Point_X-Number_Candle_Point_C; i>1; i--)
           {

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Final-Number_Candle_Point_C,Point_B);//Second Low Candle
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Final-Number_Candle_Point_C);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);//Second High Candle
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B);

            if(Number_Candle_Point_A<1 || Number_Candle_Point_B<1 || ArrayMaximum(Point_B,0,Final-Number_Candle_Point_C)<1 || ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B)<1)
              {

              }
            else
              {
               //Determine the A1 (for Point B)
               double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Shark_Min);
               double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Shark_Max);

               //Determine the A3 (for Point C)
               double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Shark_Max);
               double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Shark_Min);

               //Validation Point B and C
               Value_Point_B=Price_Information[Number_Candle_Point_B].high;
               double Value_Point_C=Price_Information[Number_Candle_Point_C].low;
               if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
                 {
                  if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                    {
                     if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,(FiboXC_D_Shark_First-Fibo_Point)))
                       {
                        Point_DD=true;
                        Pattern_Arm=true;
                        Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,(FiboXC_D_Shark_First));
                       }

                    }
                 }
              }//Final Else

            if(Point_DD)
              {
               break;
              }

            Final=Final-2;
            Incio=Incio+2;

            if(Number_Candle_Point_C<2 || Incio>=Final)
              {
               Pattern_Arm=false;
               break;
              }
           }//Final For at i

        }

      if(Pattern_Arm)
        {

         //Validation of Extrem Point in A
         double Comparice_A[];
         ArraySetAsSeries(Comparice_A,true); //Value for (Comparice_A)


         //Determine the low Candle Between X and A, include X and A
         CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Comparice_A);
         int Number_Comparice_A=Number_Candle_Point_B+ArrayMinimum(Comparice_A,0,Number_Candle_Point_X-Number_Candle_Point_B);
         double Comparice_A_Point=Price_Information[Number_Comparice_A].low;
         double Value_Point_A=Price_Information[Number_Candle_Point_A].low;

         //Compare Abvove Value with A, and if above vulue is lower, Pattern_Arm is false
         if(Comparice_A_Point<Value_Point_A)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)

         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;

         if(Comparice_D_Point>Value_Point_D)
           {
            Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,(FiboXC_D_Shark_Second));
            if(Comparice_D_Point>Value_Point_D)
              {
               Pattern_Arm=false;
              }

           }

        }

      //+------------------------------------------------------------------+
      //|Paint Pattern                                                      |
      //+------------------------------------------------------------------+
      if(Pattern_Arm && Current_Price>Value_Point_B)
        {
         //Put the Points X, A, B, C and D
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Shark_Sell");
         ObjectDelete(0,"Triangle B-C-D_Shark_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Shark_Sell",                     //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Shark_Sell",OBJPROP_COLOR,clrDarkOrchid);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Shark_Sell",                     //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Shark_Sell",OBJPROP_COLOR,clrDarkOrchid);
         ObjectDelete(0,"Shark_Sell");
         ObjectDelete(0,"Shark_Sell_Ray");
         ObjectDelete(0,"Shark_Sell_Text");

         //Flecha
         ObjectCreate(0,"Shark_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Shark_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Shark_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Shark_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Shark_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].high);
         ObjectSetInteger(0,"Shark_Sell_Text",OBJPROP_COLOR,clrDarkOrchid);
         ObjectSetString(0,"Shark_Sell_Text",OBJPROP_TEXT,"-Shark");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Shark_Sell");
         ObjectDelete(0,"Shark_Sell_Ray");
         ObjectDelete(0,"Shark_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Shark_Sell");
         ObjectDelete(0,"Triangle B-C-D_Shark_Sell");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Shark Buy                                                 |
//+------------------------------------------------------------------+
double Pattern_Shark_Buy()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point C)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_C);
      Number_Candle_Point_C=ArrayMaximum(Point_C,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C+1,k-Number_Candle_Point_C-1,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_C+1+ArrayMinimum(Point_X,0,k-Number_Candle_Point_C-1);


      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_C==k || Number_Candle_Point_C==1 || Number_Candle_Point_C==0 || Number_Candle_Point_C>=Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_C_Now=Price_Information[Number_Candle_Point_C].high;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_C_Next=Price_Information[Number_Candle_Point_C+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_C_Now<Value_Point_C_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      double Value_Point_D=0;
      double Value_Point_B=0;
      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_DD=false;
         int Incio=Number_Candle_Point_C+1;
         int Final=Number_Candle_Point_X-1;

         for(int i=Number_Candle_Point_X-Number_Candle_Point_C; i>1; i--)
           {

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Final-Number_Candle_Point_C,Point_B);//Second Low Candle
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Final-Number_Candle_Point_C);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);//Second High Candle
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B);

            if(Number_Candle_Point_A<1 || Number_Candle_Point_B<1 || ArrayMinimum(Point_B,0,Final-Number_Candle_Point_C)<1 || ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B)<1)
              {

              }
            else
              {

               //Determine the A1 (for Point B)
               double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Shark_Min);
               double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Shark_Max);

               //Determine the A3 (for Point C)
               double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Shark_Max);
               double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Shark_Min);

               //Validation Point B and C
               Point_DD=false;
               Value_Point_B=Price_Information[Number_Candle_Point_B].low;
               double Value_Point_C=Price_Information[Number_Candle_Point_C].high;
               if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
                 {
                  if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                    {
                     if(Current_Price<=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,(FiboXC_D_Shark_First-Fibo_Point)))
                       {
                        Point_DD=true;
                        Pattern_Arm=true;
                        Value_Point_D=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,FiboXC_D_Shark_First);
                       }
                    }
                 }
              }//Final Else


            if(Point_DD)
              {
               break;
              }

            Final=Final-2;
            Incio=Incio+2;

            if(Number_Candle_Point_C<2 || Incio>Final)
              {
               Pattern_Arm=false;
               break;
              }
           }//Final For at i
        }

      if(Pattern_Arm)
        {
         //Validation of Extrem Point in A
         double Comparice_A[];
         ArraySetAsSeries(Comparice_A,true); //Value for (Comparice_A)

         //Determine the High Candle Between X and A, cinclude X and A
         CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Comparice_A);
         int Number_Comparice_A=Number_Candle_Point_B+ArrayMaximum(Comparice_A,0,Number_Candle_Point_X-Number_Candle_Point_B);
         double Comparice_A_Point=Price_Information[Number_Comparice_A].high;
         double Value_Point_A=Price_Information[Number_Candle_Point_A].high;

         //Compare Abvove Value with A, and if above vulue is lower, Pattern_Arm is false
         if(Comparice_A_Point>Value_Point_A)
           {
            Pattern_Arm=false;
           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;

         if(Comparice_D_Point<Value_Point_D)
           {
            Value_Point_D=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,FiboXC_D_Shark_Second);
            if(Comparice_D_Point<Value_Point_D)
              {
               Pattern_Arm=false;
              }
           }
        }

      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm && Current_Price<Value_Point_B)
        {
         //Put the Points X, A, B, C and D
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Shark_Buy");
         ObjectDelete(0,"Triangle B-C-D_Shark_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Shark_Buy",                    //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Shark_Buy",OBJPROP_COLOR,clrDarkOrchid);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Shark_Buy",                      //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Shark_Buy",OBJPROP_COLOR,clrDarkOrchid);
         ObjectDelete(0,"Shark_Buy");
         ObjectDelete(0,"Shark_Buy_Ray");
         ObjectDelete(0,"Shark_Buy_Text");

         //Flecha
         ObjectCreate(0,"Shark_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Shark_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Shark_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Shark_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Shark_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Shark_Buy_Text",OBJPROP_COLOR,clrDarkOrchid);
         ObjectSetString(0,"Shark_Buy_Text",OBJPROP_TEXT,"-Shark");

        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Shark_Buy");
         ObjectDelete(0,"Shark_Buy_Ray");
         ObjectDelete(0,"Shark_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Shark_Buy");
         ObjectDelete(0,"Triangle B-C-D_Shark_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Shark Cypher Sell                                                |
//+------------------------------------------------------------------+
double Pattern_Cypher_Sell()
  {
   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the Low Candle (Point C)
      CopyLow(Symbol(),Temporalidad,0,k,Point_C);
      Number_Candle_Point_C=ArrayMinimum(Point_C,0,k);

      //Determine the High Candle (Point X)
      CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C+1,k-Number_Candle_Point_C-1,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_C+1+ArrayMaximum(Point_X,0,k-Number_Candle_Point_C-1);

      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_C==k || Number_Candle_Point_C==1 || Number_Candle_Point_C==0 || Number_Candle_Point_C>=Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      double Value_Point_C_Now=Price_Information[Number_Candle_Point_C].low;

      for(int n=1; n<N-1; n++)
        {
         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
         double Value_Point_C_Next=Price_Information[Number_Candle_Point_C+1].low;
         if(Pattern_Arm && (Value_Point_X_Now<Value_Point_X_Next || Value_Point_C_Now>Value_Point_C_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }

      //Determine the Second High Candle (Point B) and Point A (Second Low Candle)
      if(Pattern_Arm)
        {
         //Determine the Second Low Candle (Point A)
         Pattern_Arm=false;
         bool Point_DD=false;
         int Incio=Number_Candle_Point_C+1;
         int Final=Number_Candle_Point_X-1;

         for(int i=Number_Candle_Point_X-Number_Candle_Point_C; i>1; i--)
           {

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_C,Final-Number_Candle_Point_C,Point_B);//Second Low Candle
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMaximum(Point_B,0,Final-Number_Candle_Point_C);

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);//Second High Candle
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B);

            if(Number_Candle_Point_A<1 || Number_Candle_Point_B<1 || ArrayMaximum(Point_B,0,Final-Number_Candle_Point_C)<1 || ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B)<1)
              {

              }
            else
              {

               //Determine the A1 (for Point B)
               double Value_A1_Low=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Cypher_Min);
               double Value_A1_High=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_A,FiboXA_B_Cypher_Max);

               //Determine the A3 (for Point C)
               double Value_A3_Low=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Cypher_Max);
               double Value_A3_High=Fibo_Buy(Number_Candle_Point_B, Number_Candle_Point_A,FiboAB_C_Cypher_Min);

               //Validation Point B and C
               Point_DD=false;
               double Value_Point_B=Price_Information[Number_Candle_Point_B].high;
               double Value_Point_C=Price_Information[Number_Candle_Point_C].low;

               if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
                 {
                  if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                    {

                     if(Current_Price>=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,(FiboXC_D_Cypher-Fibo_Point)))
                       {
                        Point_DD=true;
                        Pattern_Arm=true;
                       }
                    }
                 }

              }//Final Else


            if(Point_DD)
              {
               break;
              }

            Final=Final-2;
            Incio=Incio+2;

            if(Number_Candle_Point_C<2 || Incio>Final)
              {
               Pattern_Arm=false;
               break;
              }
           }//Final For at i
        }

      if(Pattern_Arm)
        {

         //Validation of Extrem Point in A
         double Comparice_A[];
         ArraySetAsSeries(Comparice_A,true); //Value for (Comparice_A)

         //Determine the low Candle Between X and A, include X and A
         CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Comparice_A);
         int Number_Comparice_A=Number_Candle_Point_B+ArrayMinimum(Comparice_A,0,Number_Candle_Point_X-Number_Candle_Point_B);
         double Comparice_A_Point=Price_Information[Number_Comparice_A].low;
         double Value_Point_A=Price_Information[Number_Candle_Point_A].low;

         //Compare Abvove Value with A, and if above vulue is lower, Pattern_Arm is false
         if(Comparice_A_Point<Value_Point_A)
           {
            Pattern_Arm=false;

           }

         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)

         //Determine the High Candle Between 0 and C
         CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMaximum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].high;

         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,FiboXC_D_Cypher);
         double Value_Point_X=Price_Information[Number_Candle_Point_X].low;
         double Value_Point_C=Price_Information[Number_Candle_Point_C].low;

         if(Comparice_D_Point>Value_Point_D)
           {
            Pattern_Arm=false;
           }

        }
      //+------------------------------------------------------------------+
      //|Paint Pattern                                                      |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {

         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,FiboXC_D_Cypher);
         double Value_Point_D1=Fibo_Sell(Number_Candle_Point_X, Number_Candle_Point_C,FiboXC_D_Cypher+2.2);
         Final_Value=Value_Point_D;

         ObjectDelete(0,"Triangle X-A-B_Cypher_Sell");
         ObjectDelete(0,"Triangle B-C-D_Cypher_Sell");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Cypher_Sell",                     //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].high,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].low,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Cypher_Sell",OBJPROP_COLOR,clrTurquoise);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Cypher_Sell",                     //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].high,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].low,    //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Cypher_Sell",OBJPROP_COLOR,clrTurquoise);
         ObjectDelete(0,"Cypher_Sell");
         ObjectDelete(0,"Cypher_Sell_Ray");
         ObjectDelete(0,"Cypher_Sell_Text");

         //Flecha
         ObjectCreate(0,"Cypher_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_D1);
         ObjectSetInteger(0,"Cypher_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Cypher_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Cypher_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Cypher_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].high);
         ObjectSetInteger(0,"Cypher_Sell_Text",OBJPROP_COLOR,clrTurquoise);
         ObjectSetString(0,"Cypher_Sell_Text",OBJPROP_TEXT,"          -Cypher");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Cypher_Sell");
         ObjectDelete(0,"Cypher_Sell_Ray");
         ObjectDelete(0,"Cypher_Sell_Text");
         ObjectDelete(0,"Triangle X-A-B_Cypher_Sell");
         ObjectDelete(0,"Triangle B-C-D_Cypher_Sell");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Cypher Buy                                                |
//+------------------------------------------------------------------+
double Pattern_Cypher_Buy()
  {

   double Final_Value=0;
   bool Pattern_Arm=false;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {

      if(Pattern_Arm)
        {
         break;
        }

      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_C;

      //Value for High and Lowest Candles (Point X, Point A), Point B and Point C
      double Point_X[], Point_A[], Point_B[], Point_C[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)

      //+------------------------------------------------------------------+
      //|Determine the True or False Points X, A, B, C and D               |
      //+------------------------------------------------------------------+

      //Determine the High Candle (Point C)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_C);
      Number_Candle_Point_C=ArrayMaximum(Point_C,0,k);

      //Determine the Low Candle (Point X)
      CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C+1,k-Number_Candle_Point_C-1,Point_X);
      Number_Candle_Point_X=Number_Candle_Point_C+1+ArrayMinimum(Point_X,0,k-Number_Candle_Point_C-1);


      //Condition for Break
      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0 || Number_Candle_Point_C==k || Number_Candle_Point_C==1 || Number_Candle_Point_C==0 || Number_Candle_Point_C>=Number_Candle_Point_X)
        {
         Pattern_Arm=false;
        }
      else
        {
         Pattern_Arm=true;
        }

      //Determine the value Candle next to X and A
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      double Value_Point_C_Now=Price_Information[Number_Candle_Point_C].high;

      for(int n=1; n<N-1; n++)
        {

         double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
         double Value_Point_C_Next=Price_Information[Number_Candle_Point_C+1].high;
         if(Pattern_Arm && (Value_Point_X_Now>Value_Point_X_Next || Value_Point_C_Now<Value_Point_C_Next))
           {
            Pattern_Arm=false;
            break;
           }
        }



      //Determine the Second High Candle (Point C) and Point B (Second Low Candle)
      if(Pattern_Arm)
        {

         //Determine the Second Low Candle (Point C)
         Pattern_Arm=false;
         bool Point_DD=false;
         int Incio=Number_Candle_Point_C+1;
         int Final=Number_Candle_Point_X-1;


         for(int i=Number_Candle_Point_X-Number_Candle_Point_C; i>1; i--)
           {

            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_C,Final-Number_Candle_Point_C,Point_B);//Second Low Candle
            Number_Candle_Point_B=Number_Candle_Point_C+ArrayMinimum(Point_B,0,Final-Number_Candle_Point_C);

            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);//Second High Candle
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B);


            if(Number_Candle_Point_A<1 || Number_Candle_Point_B<1 || ArrayMinimum(Point_B,0,Final-Number_Candle_Point_C)<1 || ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B)<1)
              {

              }
            else
              {

               //Determine the A1 (for Point B)
               double Value_A1_High=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Cypher_Min);
               double Value_A1_Low=Fibo_Buy(Number_Candle_Point_A, Number_Candle_Point_X,FiboXA_B_Cypher_Max);

               //Determine the A3 (for Point C)
               double Value_A3_High=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Cypher_Max);
               double Value_A3_Low=Fibo_Sell(Number_Candle_Point_A, Number_Candle_Point_B,FiboAB_C_Cypher_Min);

               //Validation Point B and C
               Point_DD=false;
               double Value_Point_B=Price_Information[Number_Candle_Point_B].low;
               double Value_Point_C=Price_Information[Number_Candle_Point_C].high;


               if(Value_Point_B<Value_A1_High && Value_Point_B>Value_A1_Low) //Validation Point B
                 {
                  if(Value_Point_C<Value_A3_High && Value_Point_C>Value_A3_Low) //Validation Point C
                    {
                     if(Current_Price<=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,(FiboXC_D_Cypher-Fibo_Point)))
                       {
                        Point_DD=true;
                        Pattern_Arm=true;
                       }
                    }
                 }
              }//Final Else


            if(Point_DD)
              {
               break;
              }

            Final=Final-2;
            Incio=Incio+2;

            if(Number_Candle_Point_C<2 || Incio>Final)
              {
               Pattern_Arm=false;
               break;
              }

           }//Final For at i

        }


      if(Pattern_Arm)
        {
         //Validation of Extrem Point in A
         double Comparice_A[];
         ArraySetAsSeries(Comparice_A,true); //Value for (Comparice_A)

         //Determine the High Candle Between X and A, cinclude X and A
         CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Comparice_A);
         int Number_Comparice_A=Number_Candle_Point_B+ArrayMaximum(Comparice_A,0,Number_Candle_Point_X-Number_Candle_Point_B);
         double Comparice_A_Point=Price_Information[Number_Comparice_A].high;
         double Value_Point_A=Price_Information[Number_Candle_Point_A].high;

         //Compare Abvove Value with A, and if above vulue is lower, Pattern_Arm is false
         if(Comparice_A_Point>Value_Point_A)
           {
            Pattern_Arm=false;
           }


         //Validation of Not Contact before any candle for Point D
         double Comparice_D[];
         ArraySetAsSeries(Comparice_D,true); //Value for (Comparice_D)
         //Determine the High Candle Between 0 and C
         CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_C,Comparice_D);
         int Number_Comparice_D=ArrayMinimum(Comparice_D,0,Number_Candle_Point_C);
         double Comparice_D_Point=Price_Information[Number_Comparice_D].low;
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,FiboXC_D_Cypher);

         if(Comparice_D_Point<Value_Point_D)
           {
            Pattern_Arm=false;
           }

        }
      //+------------------------------------------------------------------+
      //|Paint Pattern_Bat                                                  |
      //+------------------------------------------------------------------+
      if(Pattern_Arm)
        {

         //Put the Points X, A, B, C and D
         double Value_Point_D=Fibo_Buy(Number_Candle_Point_C, Number_Candle_Point_X,FiboXC_D_Cypher);
         Final_Value=Value_Point_D;
         ObjectDelete(0,"Triangle X-A-B_Cypher_Buy");
         ObjectDelete(0,"Triangle B-C-D_Cypher_Buy");

         //Triangle X-A-B
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle X-A-B_Cypher_Buy",                    //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_X].time,   //Time for Point X
            Price_Information[Number_Candle_Point_X].low,   //Value for Point X
            Price_Information[Number_Candle_Point_A].time,   //Time for Point A
            Price_Information[Number_Candle_Point_A].high,    //Value for Point A
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low    //Value for Point B
         );

         //Color Triangle X-A-B
         ObjectSetInteger(0,"Triangle X-A-B_Cypher_Buy",OBJPROP_COLOR,clrTurquoise);

         //Triangle B-C-D
         ObjectCreate
         (
            0,                                               //current Chard
            "Triangle B-C-D_Cypher_Buy",                      //Namber Object
            OBJ_TRIANGLE,                                    //Object Type
            0,                                               //in Main Window
            Price_Information[Number_Candle_Point_B].time,   //Time for Point B
            Price_Information[Number_Candle_Point_B].low,   //Value for Point B
            Price_Information[Number_Candle_Point_C].time,   //Time for Point C
            Price_Information[Number_Candle_Point_C].high,   //Value for Point C
            Price_Information[0].time,                       //Time for Point D
            Value_Point_D                                     //Value for Point D
         );

         //Color Triangle B-C-D
         ObjectSetInteger(0,"Triangle B-C-D_Cypher_Buy",OBJPROP_COLOR,clrTurquoise);
         ObjectDelete(0,"Cypher_Buy");
         ObjectDelete(0,"Cypher_Buy_Ray");
         ObjectDelete(0,"Cypher_Buy_Text");

         //Flecha
         ObjectCreate(0,"Cypher_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Cypher_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Cypher_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_D);
         ObjectSetInteger(0,"Cypher_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Cypher_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low);
         ObjectSetInteger(0,"Cypher_Buy_Text",OBJPROP_COLOR,clrTurquoise);
         ObjectSetString(0,"Cypher_Buy_Text",OBJPROP_TEXT,"          -Cypher");
        }
      //+------------------------------------------------------------------+

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Cypher_Buy");
         ObjectDelete(0,"Cypher_Buy_Ray");
         ObjectDelete(0,"Cypher_Buy_Text");
         ObjectDelete(0,"Triangle X-A-B_Cypher_Buy");
         ObjectDelete(0,"Triangle B-C-D_Cypher_Buy");
        }
     }

   return Final_Value;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Pattern Aureo Sell                                                |
//+------------------------------------------------------------------+
double Pattern_Aureo_Sell()
  {

   double Final_Value=0;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {
      bool Pattern_Arm=true;
      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and, Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_A_1, Number_Candle_Point_B_1;

      //Value for High and Lowest Candles (Point X, Point A), Point B and, Point C
      double Point_X[], Point_A[], Point_B[], Point_C[], Point_A_1[], Point_B_1[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)
      ArraySetAsSeries(Point_B_1,true);
      ArraySetAsSeries(Point_A_1,true);

      //1. Determie the Low Candle (X)
      CopyLow(Symbol(),Temporalidad,0,k,Point_X);
      Number_Candle_Point_X=ArrayMinimum(Point_X,0,k);

      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0)
        {
         Pattern_Arm=false;
        }


      //2. Validation for Extreme Point X
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].low;
      if(Pattern_Arm)
        {
         for(int n=1; n<N-1; n++)
           {
            double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].low;
            if(Value_Point_X_Now>Value_Point_X_Next)
              {
               Pattern_Arm=false;
               break;
              }
           }
        }

      //3. Determine the Second low Candle (Point B), first High Candle (Point A) and, Point C.
      double Value_Point_X=0;
      double Value_Point_A=0;
      double Value_Point_B=0;
      double Value_Point_C=0;

      if(Pattern_Arm)
        {

         Pattern_Arm=false;
         int Final=Number_Candle_Point_X-2;
         int Start=2;

         for(int j=1; j<Number_Candle_Point_X-2; j++)
           {

            if(Start>=Final)
              {
               break;
              }

            //Determie the second Low Candle (B)
            CopyLow(Symbol(),Temporalidad,0,Final,Point_B);
            Number_Candle_Point_B=ArrayMinimum(Point_B,0,Final);

            //Determie the high Candle (A)
            CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B);

            if(ArrayMaximum(Point_A,0,Final-Number_Candle_Point_B)>1 && ArrayMinimum(Point_B,0,Final)>1) // Start If Principal
              {
               double Low_Point_B=Fibo_Buy(Number_Candle_Point_A,Number_Candle_Point_X,FiboXA_B_Aureo_Max);
               double High_Point_B=Fibo_Buy(Number_Candle_Point_A,Number_Candle_Point_X,FiboXA_B_Aureo_Min);
               Value_Point_B=Price_Information[Number_Candle_Point_B].low;

               if(Value_Point_B<Low_Point_B || Value_Point_B>High_Point_B)
                 {
                  Pattern_Arm=false;
                 }
               else
                 {

                  //Determine de Point C
                  double Fibo_Extension_Final=Extension_Fibo;

                  for(int i=1; i<=2; i++)
                    {

                     if(i==3 || Pattern_Arm)
                       {
                        break;
                       }

                     if(i==2)
                       {
                        Fibo_Extension_Final=Extension_Fibo2;
                       }

                     //Validation of Not Contact before any candle for Point C
                     double Comparice_C[];
                     ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)

                     //Value Point C
                     Value_Point_X=Price_Information[Number_Candle_Point_X].low;
                     Value_Point_A=Price_Information[Number_Candle_Point_A].high;
                     double Fibo_Extension=Fibo_Sell(Number_Candle_Point_A,Number_Candle_Point_X,Fibo_Extension_Final);
                     Value_Point_B=Price_Information[Number_Candle_Point_B].low;
                     Value_Point_C=Value_Point_B+(Fibo_Extension-Value_Point_X);

                     //Determine the High Candle Between 0 and B
                     CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
                     int Number_Comparice_C=ArrayMaximum(Comparice_C,0,Number_Candle_Point_B);

                     double Comparice_C_Point=Price_Information[Number_Comparice_C].high;

                     if(Comparice_C_Point<Value_Point_C)
                       {
                        if(Current_Price>Value_Point_A)
                          {
                           Pattern_Arm=true;
                          }
                       }

                    }//Final For with i
                 }//Final Else
              }//Final If Principal


            if(Pattern_Arm)
              {
               double Value_Point_A_1, Value_Point_B_1;

               //Determine the extreme Point between X and A
               CopyHigh(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Point_A_1);
               Number_Candle_Point_A_1=Number_Candle_Point_B+ArrayMaximum(Point_A_1,0,Number_Candle_Point_X-Number_Candle_Point_B);
               Value_Point_A_1=Price_Information[Number_Candle_Point_A_1].high;

               //Determine the extreme Point between C and A
               CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_A,Point_B_1);
               Number_Candle_Point_B_1=ArrayMinimum(Point_B_1,0,Number_Candle_Point_A);
               Value_Point_B_1=Price_Information[Number_Candle_Point_B_1].low;

               if(Value_Point_A_1>Value_Point_A || Value_Point_B_1<Value_Point_B)
                 {
                  Pattern_Arm=false;
                 }
              }


            Final=Final-4;
            Start=Start+4;

            if(Pattern_Arm)
              {
               break;
              }

           }//Final For with j
        }

      //4. Paint Pattern_Aureo
      if(Pattern_Arm)
        {

         ObjectDelete(0,"Line X-A_Sell");
         ObjectDelete(0,"Line X-C_Sell");
         ObjectDelete(0,"Line B-A_Sell");
         ObjectDelete(0,"Line B-C_Sell");
         Final_Value=Value_Point_C;

         //Line X-A
         ObjectCreate(0,"Line X-A_Sell",OBJ_TREND,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].high);
         ObjectSetInteger(0,"Line X-A_Sell",OBJPROP_COLOR,clrMaroon);

         //Line X-C
         ObjectCreate(0,"Line X-C_Sell",OBJ_TREND,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].low,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Line X-C_Sell",OBJPROP_COLOR,clrMaroon);

         //Line B-A
         ObjectCreate(0,"Line B-A_Sell",OBJ_TREND,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].low,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].high);
         ObjectSetInteger(0,"Line B-A_Sell",OBJPROP_COLOR,clrMaroon);

         //Line B-C
         ObjectCreate(0,"Line B-C_Sell",OBJ_TREND,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].low,+Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Line B-C_Sell",OBJPROP_COLOR,clrMaroon);

         ObjectDelete(0,"Aureo_Sell");
         ObjectDelete(0,"Aureo_Sell_Ray");
         ObjectDelete(0,"Aureo_Sell_Text");

         //Flecha
         ObjectCreate(0,"Aureo_Sell",OBJ_ARROW_DOWN,0,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Aureo_Sell",OBJPROP_COLOR,clrRed);

         //Price
         ObjectCreate(0,"Aureo_Sell_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Aureo_Sell_Ray",OBJPROP_COLOR,clrRed);

         //Text
         ObjectCreate(0,"Aureo_Sell_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].low);
         ObjectSetInteger(0,"Aureo_Sell_Text",OBJPROP_COLOR,clrMaroon);
         ObjectSetString(0,"Aureo_Sell_Text",OBJPROP_TEXT,"Aureo Pattern");
        }

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Aureo_Sell");
         ObjectDelete(0,"Aureo_Sell_Ray");
         ObjectDelete(0,"Aureo_Sell_Text");
         ObjectDelete(0,"Line X-A_Sell");
         ObjectDelete(0,"Line X-C_Sell");
         ObjectDelete(0,"Line B-A_Sell");
         ObjectDelete(0,"Line B-C_Sell");
        }

     }

   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Pattern Aureo Buy                                                 |
//+------------------------------------------------------------------+
double Pattern_Aureo_Buy()
  {

   double Final_Value=0;
   double Current_Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   for(int k=30; k<Profundidad1; k=k+10)
     {
      bool Point_DD=true;
      bool Pattern_Arm=true;
      //Array for Price
      MqlRates Price_Information[];

      //Sort Array downwartz from current candles
      ArraySetAsSeries(Price_Information,true);

      //Copy price data into the array
      int Data=CopyRates(Symbol(),Temporalidad,0,Profundidad1+N,Price_Information);

      //Numbers for High and Lowest Candles (Point X, Point A), Point B and, Point C
      int Number_Candle_Point_X, Number_Candle_Point_A, Number_Candle_Point_B, Number_Candle_Point_A_1, Number_Candle_Point_B_1;

      //Value for High and Lowest Candles (Point X, Point A), Point B and, Point C
      double Point_X[], Point_A[], Point_B[], Point_C[], Point_A_1[], Point_B_1[];

      //Sort Array Caldles
      ArraySetAsSeries(Point_X,true); //Value for (Point X)
      ArraySetAsSeries(Point_A,true); //Value for (Point A)
      ArraySetAsSeries(Point_B,true); //Value for (Point B)
      ArraySetAsSeries(Point_C,true); //Value for (Point C)
      ArraySetAsSeries(Point_B_1,true);
      ArraySetAsSeries(Point_A_1,true);

      //1. Determie the Low Candle (X)
      CopyHigh(Symbol(),Temporalidad,0,k,Point_X);
      Number_Candle_Point_X=ArrayMaximum(Point_X,0,k);

      if(Number_Candle_Point_X==k || Number_Candle_Point_X==1 || Number_Candle_Point_X==0)
        {
         Pattern_Arm=false;
        }


      //2. Validation for Extreme Point X
      double Value_Point_X_Now=Price_Information[Number_Candle_Point_X].high;
      if(Pattern_Arm)
        {
         for(int n=1; n<N-1; n++)
           {
            double Value_Point_X_Next=Price_Information[Number_Candle_Point_X+n].high;
            if(Value_Point_X_Now<Value_Point_X_Next)
              {
               Pattern_Arm=false;
               break;
              }
           }
        }

      //3. Determine the Second low Candle (Point B), first High Candle (Point A) and, Point C.
      double Value_Point_X=0;
      double Value_Point_A=0;
      double Value_Point_B=0;
      double Value_Point_C=0;

      if(Pattern_Arm)
        {

         Pattern_Arm=false;
         int Final=Number_Candle_Point_X-2;
         int Start=2;

         for(int j=1; j<Number_Candle_Point_X-2; j++)
           {

            if(Start>=Final)
              {
               break;
              }

            //Determie the second High Candle (B)
            CopyHigh(Symbol(),Temporalidad,0,Final,Point_B);
            Number_Candle_Point_B=ArrayMaximum(Point_B,0,Final);

            //Determie the Low Candle (A)
            CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Final-Number_Candle_Point_B,Point_A);
            Number_Candle_Point_A=Number_Candle_Point_B+ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B);

            if(ArrayMaximum(Point_B,0,Final)>1 && ArrayMinimum(Point_A,0,Final-Number_Candle_Point_B)>1) // Start If Principal
              {
               double Low_Point_B=Fibo_Sell(Number_Candle_Point_X,Number_Candle_Point_A,FiboXA_B_Aureo_Min);
               double High_Point_B=Fibo_Sell(Number_Candle_Point_X,Number_Candle_Point_A,FiboXA_B_Aureo_Max);
               Value_Point_B=Price_Information[Number_Candle_Point_B].high;

               if(Value_Point_B<Low_Point_B || Value_Point_B>High_Point_B)
                 {
                  Pattern_Arm=false;
                 }
               else
                 {

                  //Determine de Point C
                  double Fibo_Extension_Final=Extension_Fibo;

                  for(int i=1; i<=2; i++)
                    {
                     if(i==3 || Pattern_Arm)
                       {
                        break;
                       }

                     if(i==2)
                       {
                        Fibo_Extension_Final=Extension_Fibo2;
                       }

                     //Validation of Not Contact before any candle for Point C
                     double Comparice_C[];
                     ArraySetAsSeries(Comparice_C,true); //Value for (Comparice_C)

                     //Value Point C
                     Value_Point_X=Price_Information[Number_Candle_Point_X].high;
                     Value_Point_A=Price_Information[Number_Candle_Point_A].low;
                     double Fibo_Extension=Fibo_Buy(Number_Candle_Point_X,Number_Candle_Point_A,Extension_Fibo);
                     Value_Point_B=Price_Information[Number_Candle_Point_B].high;
                     Value_Point_C=Value_Point_B-(Value_Point_X-Fibo_Extension);


                     //Determine the Low Candle Between 0 and B
                     CopyLow(Symbol(),Temporalidad,0,Number_Candle_Point_B,Comparice_C);
                     int Number_Comparice_C=ArrayMinimum(Comparice_C,0,Number_Candle_Point_B);
                     double Comparice_C_Point=Price_Information[Number_Comparice_C].low;

                     if(Comparice_C_Point>Value_Point_C)
                       {
                        if(Current_Price<Value_Point_A)
                          {
                           Pattern_Arm=true;
                           break;
                          }
                       }
                    }//Final For with i
                 }//Final Else
              }//Final If Principal


            if(Pattern_Arm)
              {

               double Value_Point_A_1, Value_Point_B_1;

               //Determine the extreme Point between X and B
               CopyLow(Symbol(),Temporalidad,Number_Candle_Point_B,Number_Candle_Point_X-Number_Candle_Point_B,Point_A_1);
               Number_Candle_Point_A_1=Number_Candle_Point_B+ArrayMinimum(Point_A_1,0,Number_Candle_Point_X-Number_Candle_Point_B);
               Value_Point_A_1=Price_Information[Number_Candle_Point_A_1].low;

               //Determine the extreme Point between C and A
               CopyHigh(Symbol(),Temporalidad,0,Number_Candle_Point_A,Point_B_1);
               Number_Candle_Point_B_1=ArrayMaximum(Point_B_1,0,Number_Candle_Point_A);
               Value_Point_B_1=Price_Information[Number_Candle_Point_B_1].high;

               if(Value_Point_A_1<Value_Point_A || Value_Point_B_1>Value_Point_B)
                 {
                  Pattern_Arm=false;
                 }
              }


            Final=Final-4;
            Start=Start+4;

            if(Pattern_Arm)
              {
               break;
              }

           }//Final For with j
        }

      //4. Paint Pattern_Aureo
      if(Pattern_Arm)
        {
         ObjectDelete(0,"Line X-A_Buy");
         ObjectDelete(0,"Line X-C_Buy");
         ObjectDelete(0,"Line B-A_Buy");
         ObjectDelete(0,"Line B-C_Buy");
         Final_Value=Value_Point_C;

         //Line X-A
         ObjectCreate(0,"Line X-A_Buy",OBJ_TREND,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].high,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Line X-A_Buy",OBJPROP_COLOR,clrMaroon);

         //Line X-C
         ObjectCreate(0,"Line X-C_Buy",OBJ_TREND,0,Price_Information[Number_Candle_Point_X].time,Price_Information[Number_Candle_Point_X].high,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Line X-C_Buy",OBJPROP_COLOR,clrMaroon);

         //Line B-A
         ObjectCreate(0,"Line B-A_Buy",OBJ_TREND,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].high,Price_Information[Number_Candle_Point_A].time,Price_Information[Number_Candle_Point_A].low);
         ObjectSetInteger(0,"Line B-A_Buy",OBJPROP_COLOR,clrMaroon);

         //Line B-C
         ObjectCreate(0,"Line B-C_Buy",OBJ_TREND,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].high,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Line B-C_Buy",OBJPROP_COLOR,clrMaroon);

         ObjectDelete(0,"Aureo_Buy");
         ObjectDelete(0,"Aureo_Buy_Ray");
         ObjectDelete(0,"Aureo_Buy_Text");

         //Flecha
         ObjectCreate(0,"Aureo_Buy",OBJ_ARROW_UP,0,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Aureo_Buy",OBJPROP_COLOR,clrGreen);

         //Price
         ObjectCreate(0,"Aureo_Buy_Ray",OBJ_ARROW_RIGHT_PRICE,0,Price_Information[0].time,Value_Point_C);
         ObjectSetInteger(0,"Aureo_Buy_Ray",OBJPROP_COLOR,clrGreen);

         //Text
         ObjectCreate(0,"Aureo_Buy_Text",OBJ_TEXT,0,Price_Information[Number_Candle_Point_B].time,Price_Information[Number_Candle_Point_B].high);
         ObjectSetInteger(0,"Aureo_Buy_Text",OBJPROP_COLOR,clrMaroon);
         ObjectSetString(0,"Aureo_Buy_Text",OBJPROP_TEXT,"Aureo Pattern");
        }

      if(Pattern_Arm)
        {
         break;
        }

      if(!Pattern_Arm)
        {
         ObjectDelete(0,"Aureo_Buy");
         ObjectDelete(0,"Aureo_Buy_Ray");
         ObjectDelete(0,"Aureo_Buy_Text");
         ObjectDelete(0,"Line X-A_Buy");
         ObjectDelete(0,"Line X-C_Buy");
         ObjectDelete(0,"Line B-A_Buy");
         ObjectDelete(0,"Line B-C_Buy");
        }

     }
   return Final_Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
void OnTimer()
  {
   Time_For_Gartley=true;
   Time_For_Bat=true;
   Time_For_Butterfly=true;
   Time_For_Crab=true;
   Time_For_Shark=true;
   Time_For_Cypher=true;
   Time_For_Poseidon=true;
   Time_For_Aureo=true;
   Time=true;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateSession()
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION))
      return;

   double maxprice = ChartGetDouble(0, CHART_PRICE_MAX),
          minprice = ChartGetDouble(0, CHART_PRICE_MIN),
          pix_height = (double)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS),
          poin1 = (maxprice - minprice) / pix_height;

   if(bar1 != iBars(_Symbol, PERIOD_H1) || mp != maxprice)
     {
      for(int x = 0; x < ShowSession; x++)
        {
         datetime _begin = iTime(_Symbol, PERIOD_D1, x) + start_sidney * 3600;
         datetime _end = iTime(_Symbol, PERIOD_D1, x) + end_sidney * 3600;

         if(start_sidney > end_sidney)
            _begin = iTime(_Symbol, PERIOD_D1, x) + (start_sidney - 24) * 3600;

         double price1 = MathMin(iHigh(_Symbol, PERIOD_D1, x) + 4 * (InpFontSize + 5) * poin1, maxprice),
                price2 = price1 - (InpFontSize + 5) * poin1;

         if(TimeCurrent() + 7200 >= _begin)
           {
            createObject("sessionSidney" + string(x), OBJ_RECTANGLE, _begin, _end, price1, price2, InpColorSidney);
            if(InpShowLabels)
               createObject("sessionLblSidney" + string(x), OBJ_TEXT, _begin, _end, price1, price2, InpFontColor);
            if(InpShowVLines)
               createObject("sessionVLSidney" + string(x), OBJ_VLINE, _begin, _end, price1, price2, InpColorSidney);
           }
         else
           {
            ObjectDelete(0, "sessionSidney" + string(x));
            ObjectDelete(0, "sessionLblSidney" + string(x));
            ObjectDelete(0, "sessionVLSidney" + string(x));
           }

         _begin = iTime(_Symbol, PERIOD_D1, x) + start_tokio * 3600;
         _end = iTime(_Symbol, PERIOD_D1, x) + end_tokio * 3600;

         if(start_tokio > end_tokio)
            _begin = iTime(_Symbol, PERIOD_D1, x) + (start_tokio - 24) * 3600;

         if(TimeCurrent() + 7200 >= _begin || x > 0)
           {
            price1 = price2;
            price2 = price1 - (InpFontSize + 5) * poin1;

            createObject("sessionTokyo" + string(x), OBJ_RECTANGLE, _begin, _end, price1, price2, InpColorTokio);
            if(InpShowLabels)
               createObject("sessionLblTokyo" + string(x), OBJ_TEXT, _begin, _end, price1, price2, InpFontColor);
            if(InpShowVLines)
               createObject("sessionVLTokyo" + string(x), OBJ_VLINE, _begin, _end, price1, price2, InpColorTokio);
           }
         else
           {
            ObjectDelete(0, "sessionTokyo" + string(x));
            ObjectDelete(0, "sessionLblTokyo" + string(x));
            ObjectDelete(0, "sessionVLTokyo" + string(x));
           }

         _begin = iTime(_Symbol, PERIOD_D1, x) + start_london * 3600;
         _end = iTime(_Symbol, PERIOD_D1, x) + end_london * 3600;

         if(start_london > end_london)
            _begin = iTime(_Symbol, PERIOD_D1, x) + (start_london - 24) * 3600;

         if(TimeCurrent() + 7200 >= _begin || x > 0)
           {
            price1 = price2;
            price2 = price1 - (InpFontSize + 5) * poin1;

            createObject("sessionLondon" + string(x), OBJ_RECTANGLE, _begin, _end, price1, price2, InpColorLondon);
            if(InpShowLabels)
               createObject("sessionLblLondon" + string(x), OBJ_TEXT, _begin, _end, price1, price2, InpFontColor);
            if(InpShowVLines)
               createObject("sessionVLLondon" + string(x), OBJ_VLINE, _begin, _end, price1, price2, InpColorLondon);
           }
         else
           {
            ObjectDelete(0, "sessionLondon" + string(x));
            ObjectDelete(0, "sessionLblLondon" + string(x));
            ObjectDelete(0, "sessionVLLondon" + string(x));
           }

         _begin = iTime(_Symbol, PERIOD_D1, x) + start_new_york * 3600;
         _end = iTime(_Symbol, PERIOD_D1, x) + end_new_york * 3600;

         if(start_new_york > end_new_york)
            _end = iTime(_Symbol, PERIOD_D1, x) + (end_new_york + 24) * 3600;

         if(TimeCurrent() + 7200 >= _begin || x > 0)
           {
            price1 = price2;
            price2 = price1 - (InpFontSize + 5) * poin1;

            createObject("sessionNewYork" + string(x), OBJ_RECTANGLE, _begin, _end, price1, price2, InpColorNewYork);
            if(InpShowLabels)
               createObject("sessionLblNewYork" + string(x), OBJ_TEXT, _begin, _end, price1, price2, InpFontColor);
            if(InpShowVLines)
               createObject("sessionVLNewYork" + string(x), OBJ_VLINE, _begin, _end, price1, price2, InpColorNewYork);
           }
         else
           {
            ObjectDelete(0, "sessionNewYork" + string(x));
            ObjectDelete(0, "sessionLblNewYork" + string(x));
            ObjectDelete(0, "sessionVLNewYork" + string(x));
           }
        }
     }
   bar1 = iBars(_Symbol, PERIOD_H1);
   mp = maxprice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createObject(string objname1, ENUM_OBJECT objtpe, datetime time1, datetime time2, double price1, double price2, color warna)
  {
   ObjectCreate(0, objname1, objtpe, 0, 0, 0);
   ObjectSetInteger(0, objname1, OBJPROP_TIME, 0, time1);
   ObjectSetInteger(0, objname1, OBJPROP_TIME, 1, time2);
   ObjectSetInteger(0, objname1, OBJPROP_COLOR, warna);
   ObjectSetInteger(0, objname1, OBJPROP_FILL, true);
   ObjectSetInteger(0, objname1, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, objname1, OBJPROP_BACK, true);
   ObjectSetDouble(0, objname1, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(0, objname1, OBJPROP_PRICE, 1, price2);
   string txt = StringFind(objname1, "Sidney") > 0 ? " Sidney" : StringFind(objname1, "Tokyo") > 0 ? " Tokyo" : StringFind(objname1, "London") > 0 ? " London" : " New York";
   ObjectSetString(0, objname1, OBJPROP_TEXT, txt);
   if(StringFind(objname1, "Lbl") > 0)
     {
      ObjectSetInteger(0, objname1, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(0, objname1, OBJPROP_FONT, InpFontName);
     }
   if(StringFind(objname1, "VL") > 0)
     {
      ObjectSetString(0, objname1, OBJPROP_TOOLTIP, txt);
      ObjectSetInteger(0, objname1, OBJPROP_STYLE, STYLE_DOT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FilterSession()
  {
   if(TradeOnSidney)
     {
      if(start_sidney <= end_sidney)
        {
         if(Hour1() >= start_sidney && Hour1() < end_sidney)
            return true;
        }
      else
        {
         if(Hour1() >= start_sidney || Hour1() < end_sidney)
            return true;
        }
     }
   if(TradeOnTokyo)
     {
      if(start_tokio <= end_tokio)
        {
         if(Hour1() >= start_tokio && Hour1() < end_tokio)
            return true;
        }
      else
        {
         if(Hour1() >= start_tokio || Hour1() < end_tokio)
            return true;
        }
     }
   if(TradeOnLondon)
     {
      if(start_london <= end_london)
        {
         if(Hour1() >= start_london && Hour1() < end_london)
            return true;
        }
      else
        {
         if(Hour1() >= start_london || Hour1() < end_london)
            return true;
        }
     }
   if(TradeOnNewYork)
     {
      if(start_new_york <= end_new_york)
        {
         if(Hour1() >= start_new_york && Hour1() < end_new_york)
            return true;
        }
      else
        {
         if(Hour1() >= start_new_york || Hour1() < end_new_york)
            return true;
        }
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PermitOperation()
  {
   if(FilterSession())
     {
      if(!TradeOnSidney)
        {
         if(start_sidney <= end_sidney)
           {
            if(Hour1() >= start_sidney && Hour1() < end_sidney)
               return false;
           }
         else
           {
            if(Hour1() >= start_sidney || Hour1() < end_sidney)
               return false;
           }
        }
      if(!TradeOnTokyo)
        {
         if(start_tokio <= end_tokio)
           {
            if(Hour1() >= start_tokio && Hour1() < end_tokio)
               return false;
           }
         else
           {
            if(Hour1() >= start_tokio || Hour1() < end_tokio)
               return false;
           }
        }
      if(!TradeOnLondon)
        {
         if(start_london <= end_london)
           {
            if(Hour1() >= start_london && Hour1() < end_london)
               return false;
           }
         else
           {
            if(Hour1() >= start_london || Hour1() < end_london)
               return false;
           }
        }
      if(!TradeOnNewYork)
        {
         if(start_new_york <= end_new_york)
           {
            if(Hour1() >= start_new_york && Hour1() < end_new_york)
               return false;
           }
         else
           {
            if(Hour1() >= start_new_york || Hour1() < end_new_york)
               return false;
           }
        }
     }

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Hour1()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   return(dt.hour);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
