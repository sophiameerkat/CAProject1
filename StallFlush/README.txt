if(branch taken)
	flush IF/ID, instruction in IF/ID becomes all 0's. Control will take this zero instruction as NoOp;

if(load instruction leads to data hazard){
	HazardDetectionUnit send NoOp signal to ID/EX, ID/EX runs NoOp in the next clk;
	HazardDetectionUnit send Stall signal to IF/ID, IF/ID does nothing to stall;
}