
module direction(dir, block, orientation, inputDir);
//dir is 0 -> up, 1 -> down
//       2 -> right, 3 -> left
//block is binary rep of which block we are selecting
//orientation 1 -> up/down, 0 -> left/right
input block[3:0];
input orientation;
input inputDir;
output dir;

assign dir = inputDir;

if (orientation == 1'b0) //orientation is up/down
begin 
    if (dir != 0'b0 && dir != 1'b0)
        assign dir = -1; //-1 if invalid direction
end

if (orientation == 0'b0) //orientation is up/down
begin 
    if (dir != 2'b0 && dir != 3'b0)
        assign dir = -1; //-1 for invalid direction
end
endmodule

module 






module mux2to1(x, y, s, m);
input x;
input y;
input s;
output m;

assign m = x && ~s || y && s;
endmodule