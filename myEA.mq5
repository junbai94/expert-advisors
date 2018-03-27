#include <stderror.mqh>
#include <stdlib.mqh>


extern float entry = 10.0;
extern float TP;
extern float SL;


void OnInit(void){
	Print("EA COMMENCING");

	// terminate EA if auto trade is not allowed
	if (! MQL_TRADE_ALLOWED) {
		Alert("Auto Trade Setting Disabled. Please turn it on");
		deinit();
	}
}


void OnDeinit(void){
	Print("EA TERMINATED");
}


void OnTick(void){
	total = OrdersTotal();
	if !(total == 0) adjustPos(); else openTrade();
}


// Helper functions
//+===================================================
//+===================================================
void adjustPos(void){
	/*
	Close position if hit TP or SL
	*/
	if (OrderSelect(0, SELECT_BY_POS) != false){

	}
}


int marketOrder(int op, double volume=0.01, int magic=0, string comment=NULL, int slippage=1){
	/*
	Make market order. Default volume is 0.01 lot. Slippage is 1 point of current pair
	*/
	// make order 
	int ticket
	if (op==OP_BUY){
		ticket = OrderSend(Symbol(), op, volume, Ask, slippage, 0, 0, comment, magic);
	}  
	else if (op==OP_SELL){
		ticket = OrderSend(Symbol(), op, volume, Bid, slippage, 0, 0, comment, magic);
	}
	

	// Error handling
	if(ticket == -1){
		// Alert when error
		errorAlert("Order Failed");
	}

	return ticket;
}


void closeOrder(int ticket==NULL){
	/*
	Close an order at market price
	*/
	// Select top-most order in pool
	if (!OrderSelect(0, SELECT_BY_POS)){
		errorAlert("No trade in pool");
	}

	// close order 
	if (OrderType() == OP_BUY){
		if(!OrderClose(OrderTicket(), OrderLots(), Bid, 1)){
			errorAlert("Order Close Failed");
		}
	}
	else if (OrderType() == OP_SELL){
		if(!OrderClose(OrderTicket(), OrderLots(), Ask, 1)){
			errorAlert("Order Close Failed");
		}
	}
}


void errorAlert(string msg){
	Alert(msg);
	int check = GetLastError();
	if(check != ERR_NO_ERROR) Print("Error: ", ErrorDescription(check));
}


void openTrade(void){
	// get previous bars high and low
	high = High[1];
	low = Low[1];
	diff = (high-low) * 10000;

	// open position
	if (diff >= entry){
		// determine direction
		if (Close[1] >= Open[1]) marketOrder(OP_SELL); else marketOrder(OP_BUY);
	}
}