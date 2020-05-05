int cell[];                                   //Holds the main cell array
int cell_Scale = 12;                          //The scale for the cells visual representation  
int gridSize;                                 //The visual size of the matrix 
int simulationFrameRate = 10;                 //Frames to sit out between calling of the next iteration of the simulation
int simulationFrameRateMax = 50;              //Upper limit for simulationFrameRate (A high value slows the simulation, a value of 1 calls an iteration every frame
float state_chance = 0.5f;                    //The chance for a square to be populated with a living cell upon initial seeding of the matrix
boolean useTestNeighbourCounter = false;      //If enabled will perform a test neighbourcount on the cell at (10,10) highlighted in red and logged in the console
boolean paused = false;                       //Keeps track of the pause state 
boolean deletePaintMode = false;              //Is the paintmode set to delete?
String consoleMessageSeparator = "  ///  ";   //Separates messages in the console during debugging
int ruleSet = 1;                              //Currently defined ruleSets are 1 (original Conway) and 2 (alternative populative ruleset)

//Creates the matrix and populates it by looping through the array and flipping cells alive (1) based on the chance logged in state_chance.
//If useTestNeighbourCounter is true performs the test for debugging purposes.
void setup()
{
  size(1200,900);
  gridSize = width/cell_Scale;
  
  cell = new int[gridSize * gridSize];
  
  for(int i = 0; i < cell.length; i++)
  {
     if(random(1) < state_chance)
     {
       cell[i] = 1;
     }
     else
     {
       cell[i] = 0;
     }
  }  
  if(useTestNeighbourCounter)
  {
    print(neighbourCount(10, 10));
  }   
}

//Handles the visual representation of the matrix. The background turns red(255,180,180) during pause for visual clarity.
//Lastly calls for the iteration to progress one step every X frames as stated in simulationFrameRate variable.
void draw()
{
  if(!paused)
  {
    background(235,235,255);
  }else
  {
    background(225,180,180);
  }
  
  drawCells();
  drawGrid();
  
  if(frameCount % simulationFrameRate == 0 && !paused)
  {
    iterationForward();  
  }  
}

//Performs a count of living cells around the cell with specified positions (x,y). Excludes the count-performing cell.
//Returns the number of neighbours counted.
int neighbourCount(int i, int j)
{
  int num = 0;
  
  for(int x = -1; x <= 1; x++)
  {
    for(int y = -1; y <= 1; y++)
    {
      if(x == 0 && y == 0) continue;
      int ni = i + x;
      int nj = j + y;
      num += cell[positionLocator(ni, nj)];
    }
  }
  
  return num;
}

//--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
//Advances the simulation one iteration when called. The existing array is copied(cloned), conditions for death/survival analysed by looping through the array,
//while changes in the next iteration are saved into the nextGeneration array. When the loop is concluded the old generation (cell array) is overwritten with the next generation.
//--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
void iterationForward()
{
  if(ruleSet == 1)
  {
    applyRuleSet1();
  }
  else if(ruleSet ==2)
  {
    applyRuleSet2();
  }
}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// This is an alternative exploratory ruleset that is highly populative and stagnates easily
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void applyRuleSet2()
{
  int[] nextGeneration = cell.clone();  
  for(int i = 0; i < gridSize; i++)
  {
    for(int j = 0; j < gridSize; j++)
    {
      int n = neighbourCount(i, j);
      if(cell[positionLocator(i, j)] == 1)  //If the currently analysed cell is alive (1)...
      {        
        
        //--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
        //This segment determines the conditions for death/survival of cells.
        //--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----           
        if(n < 2 || n > 4)
        {
          //The cell will be dead in the next generation (1= alive, 0= dead)
          nextGeneration[positionLocator(i, j)] = 0;  
        }
      }
      else
      {
        float random = random(10);
        if (n == 3 && random >= 0.65)
        {
          //The cell will be alive in the next generation (1= alive, 0= dead)
          nextGeneration[positionLocator(i, j)] = 1;
        }  
      }      
    }
  }
  //Finalises the condition analysis and overwrites the cell array holding the current generation with the resulting new generation.
  cell = nextGeneration;
}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// This is the specified original ruleset as determined by Conway
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void applyRuleSet1()
{
  int[] nextGeneration = cell.clone();  
  for(int i = 0; i < gridSize; i++)
  {
    for(int j = 0; j < gridSize; j++)
    {
      int n = neighbourCount(i, j);
      if(cell[positionLocator(i, j)] == 1)  //If the currently analysed cell is alive (1)...
      {        
        
        //--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
        //This part determines the conditions for death/survival of cells.
        //--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----           
        if(n < 2 || n > 3)
        {
          //The cell will be dead in the next generation (1= alive, 0= dead)
          nextGeneration[positionLocator(i, j)] = 0; 
        }
      }
      else
      {
        if (n == 3)
        {
          //The cell will be alive in the next generation (1= alive, 0= dead)
          nextGeneration[positionLocator(i, j)] = 1;
        }  
      }      
    }
  }
  //Finalises the condition analysis and overwrites the cell array holding the current generation with the resulting new generation.
  cell = nextGeneration;
}
  
//Draws the visual grid.
void drawGrid()
{
  stroke(175);
  for(int i = 0; i < gridSize; i++)
  {
    line(i * cell_Scale, 0, i* cell_Scale, height);
    line(0, i * cell_Scale, width, i * cell_Scale);
  }
}  

//Draws the cells in the ongoing iteration. For testing purposes, if useTestNeighbourCounter is enabled, the cell with position (10,10)
//will be highlighted in red if it is alive, and its neighbourCount value will be printed to the application console.
void drawCells()
{
  noStroke();
  fill(25);
  for(int i = 0; i < gridSize; i++)
  {
    for(int j = 0; j< gridSize; j++)
    {
      if(cell[positionLocator(i, j)] == 1)
      {
        if(i == 10 && j == 10 && useTestNeighbourCounter) 
        {           
          fill(255,0,0);
        }else
        {
          fill(0);
        }
        rect(i * cell_Scale, j * cell_Scale, cell_Scale, cell_Scale);
      }      
    }
  }
}

//Returns the cells position relative to the grid size for visualistion.
int positionLocator(int i, int j)
{
  i = constrain(i, 0, gridSize - 1);
  j = constrain(j, 0, gridSize - 1);
  
  return (i + j * gridSize);
}

//Calls for the specified positions square to be edited via user input (Paintmode)
//Parameter cellState is controlled indirectly by deletePaintMode bool, determining wether a cell is added or ix existing removed
void editLocation(int i, int j, int cellState)
{
  cell[positionLocator(i,j)] = cellState;
}

//Loops through the entire cell array, setting the state of all cells to (0) = dead
void clearMatrix()
{
  for(int i = 0; i < cell.length; i++)
    {
      cell[i] = 0;
    }    
}

//PaintMode, deletePaintMode can be toggled via user input to switch between adding/erasing cells
void mouseDragged()
{
  if(!deletePaintMode)
  {
    editLocation(mouseX/cell_Scale, mouseY/cell_Scale, 1);  
  }else if(deletePaintMode)
  {
    editLocation(mouseX/cell_Scale, mouseY/cell_Scale, 0);
  }  
}  

//Controls and detects user input
// 1 - Sets the ruleset to be applied by the iterationForward() method to 1
// 2 - Sets the ruleset to be applied by the iterationForward() method to 2
// P - Pauses/Unpauses the simulation
// C - Clears the matrix of all living cells
// U - Increases the simulation speed, by lowering the value of 'simulationFrameRate'
// N - Decreases the simulation speed, by increasing the value of 'simulationFrameRate'
void keyPressed()
{
  if(key == '1')
  {
    ruleSet = 1;
    print("Ruleset: " + (ruleSet));
  }else if(key == '2')
  {
    ruleSet = 2;
    print("Ruleset: " + (ruleSet));
  }else if(key == '3' || key == '4' || key == '5' || key == '6' || key == '7')
  {
    print("No such ruleset defined.");
  }  
  
  if(key == 'u')
  {
      simulationFrameRate = constrain (simulationFrameRate -3, 1, simulationFrameRateMax);   
      print("Automatically iterating on every " + (simulationFrameRate) + "th frame.");
  }
  if(key == 'n')
  {
      simulationFrameRate = constrain (simulationFrameRate +3, 1, simulationFrameRateMax);
      print("Automatically iterating on every " + (simulationFrameRate) + "th frame.");
  }     
  if(key == 'p')
  {
    paused = !paused;
    if(paused)
    {
      print("Paused simulation");      
    }
    else if(!paused)
    {
      print("Unpaused simulation.");
    }
  }
  if(key == 'd')
  {
    deletePaintMode = !deletePaintMode;
    if(deletePaintMode)
    {
      print("Painting mode: Delete cells.");      
    }
    else if(!deletePaintMode)
    {
      print("Painting mode: Create cells.");
    }
  }
  if(key == 'c')
  {      
      clearMatrix();
      print("Matrix cleared.");
  }  
  if(key == 'r')
  {      
      setup();
      print("Matrix reset.");
  }  
} 
