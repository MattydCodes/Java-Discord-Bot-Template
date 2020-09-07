

String prefix = "!"; //Change to whatever you want the bot to respond to, ie !command..

String ProjectPath = ""; //Global variable for project path..



void setup(){
  //Code here runs once at the start... Make sure to use the discord developer portal and create a bot, take it's token and edit the botToken.txt file in the data folder. (ctrl + k) To access the project folder.
  
  
  ProjectPath = dataPath("").replaceAll("\\\\","/"); //Sets to the path of the project file.
  ProjectPath = ProjectPath.substring(0,ProjectPath.length()-4);    
 
  initBot(OnlineStatus.ONLINE,Game.playing("With A Bot That Totally Works :^)")); //Example parameters.. Other statuses include IDLE, DO_NOT_DISTURB, INVISIBLE, OFFLINE, ONLINE, UNKNOWN(?)
}



void draw(){
  //Code here runs every frame...
}


class Commands extends ListenerAdapter{ //The class is used to recieve events and execute code based on it... Please add any functionality inside of here so that it works with the jda code I wrote to setup the bot.
                                        //(it's not much code though so if you want to change it just look at it x).. )
                                        
  public void onGuildMessageReceived(GuildMessageReceivedEvent event){ //This code will run whenever a message is recieved.
    
    List<Message.Attachment> Attachment = event.getMessage().getAttachments(); //Attachments to the messages ie images.
    
    String[] args = event.getMessage().getContentRaw().split("\\s+"); //Splits the message based on space.
    String firstArg = args[0]; //To compare to functions.
    String userName = event.getAuthor().getName(); //Username of the Author.
    
   
    //All of this is example code.. feel free to remove it once you understand the code.
   
    
    if(isCommand("Ping",firstArg)){
      sendMessage(event,"Pong");
    }
    
    if(isCommand("UserName",firstArg)){
      sendMessage(event,userName);
    }
    
    if(isCommand("GetImage",firstArg)){
      sendImage(event,"data/sample.png");
    }
    
    if(isCommand("GenerateImage",firstArg)){
      exampleImageGenerationExample(event);
    }
    
    if(isCommand("EdgeDetect",firstArg)){
      float brightness = 1;      
      
      if(args.length == 2){ //If the user has sent more than one argument ie !edgedetect 2. Try converting the second value into a float to use as a multiplier for brightness in the edgedetection.
        try{
          brightness = float(args[1]);
        }catch(Exception e){
          brightness = 1;
        }
      }
      
      
      edgeDetectionExample(event,Attachment,brightness);
    }
    
  }  
  
}




//START OF EXAMPLE CODE: =======================================================================================



void exampleImageGenerationExample(GuildMessageReceivedEvent event){ //Just to give an example of the processings image interface.

  noiseSeed(int(random(3285923))); //Sets new random seed so the image generated is different.
    
  PImage img = createImage(500,500,RGB);
  img.loadPixels(); //Loading the pixel array.
  
  color col1 = color(255,0,0);
  color col2 = color(0,255,100);
  
  for(int x = 0; x < 500; x++){
    for(int y = 0; y < 500; y++){
      img.pixels[x+y*img.width] = lerpColor(col1,col2,noise(x/200.0,y/200.0)); // The pixel array is 1 dimensional so we have to access it like so.. x + y * imageWidth.. Noise is perlinNoise.
    }
  }
  
  img.updatePixels(); //Once the pixels have been edited we update the array(?) idk tbh but you just have to do it lol. 
  
  img.save("data/generate.png"); //How processing saves images.
  
  sendImage(event,"data/generate.png"); //Pass the event and address to send an image.
  
}



void edgeDetectionExample(GuildMessageReceivedEvent event, List<Message.Attachment> Attachment, float brightness){ //To give an example of attachment downloading and processing.. 

  float[][] Gx = new float[][]{new float[]{47,162,47},new float[]{0,0,0},new float[]{-47,-162,-47}}; //Filters for the edgedetection..
  float[][] Gy = new float[][]{new float[]{47,0,-47},new float[]{162,0,-162},new float[]{47,0,-47}};
  Attachment.get(0).download(new File(ProjectPath + "data/Attachment.png"));
  
  PImage img = loadImage("data/Attachment.png");
  PImage tosend = createImage(img.width,img.height,RGB);
  
  tosend.loadPixels();
  img.loadPixels();
  
  for(int x = 0; x < img.width; x++){
    for(int y = 0; y < img.height; y++){      
      
      float[][] input = new float[3][3]; //An array to hold the brightness of each pixel in a 3x3 grid.
      
      for(int x1 = -1; x1 < 2; x1++){
        for(int y1 = -1; y1 < 2; y1++){
          
          int x2 = constrain(x+x1,0,img.width-1); //Makes sure the coordinates are within the image dimensions otherwise an error will be thrown from accessing a non existant value in the image.pixels array.
          int y2 = constrain(y+y1,0,img.height-1); // ^
          
          input[x1+1][y1+1] = Brightness(img.pixels[x2+y2*img.width])/255.0;
        }
      }      
      
      float gxMult = getMultied(Gx,input); //Multiplies the input array by the values in the Gx array and returns the total.
      float gyMult = getMultied(Gy,input); //Multiplies the input array by the values in the Gy array and returns the total. 
     
      float mag = sqrt(pow(gxMult,2)+pow(gyMult,2))*1.5; //Calculates how strong the edge is.
      float angle = atan2(gyMult,gxMult); //Calculates the angle of the edge.
      float mult = PI/2; //Value used to mess with the colourisation.
      
      
      //Setting rgb values based on the angle and strength of edge.
      
      float red = max(sin(angle*mult),0)*mag;
      float green = max(sin((angle+1*PI/3.0)*mult),0)*mag;
      float blue = max(sin((angle+2*PI/3.0)*mult),0)*mag;
      
      tosend.pixels[x+y*img.width] = color(red*brightness,green*brightness,blue*brightness); //Setting the new image we're creating's pixel to equal this value.
      
      
    }
  }  
  
  tosend.updatePixels();
  
  tosend.save("data/tosend.png");
  
  sendImage(event,"data/tosend.png");
  
}



float getMultied(float[][] matrix, float[][] input){ //Used for the edgedetection example..
  float count = 0;
  for(int x = 0; x < 3; x++){
    for(int y = 0; y < 3; y++){
      count+=matrix[x][y]*input[x][y];
    }
  }
  return count;
}



float Brightness(color c){ //Used for the edgedetection example..
  return (red(c)+green(c)+blue(c))/3.0;
}



//END OF EXAMPLE CODE: =======================================================================================




void sendMessage(GuildMessageReceivedEvent event, String message){
  event.getChannel().sendTyping().queue(); //Sends a message that the bot is typing.
  event.getChannel().sendMessage(message).queue(); //Sends the message.
}



void sendImage(GuildMessageReceivedEvent event, String address){ //Address to the image, ie "data/sample.png"
  try{
    event.getChannel().sendTyping().queue();
    event.getChannel().sendFile(loadFile(address),"img.png").complete(); 
  }catch(Exception e){
    println(e);
  }
}



File loadFile(String address){
  try{
    return new File(ProjectPath+address);
  }catch(Exception e){
    println(e);
  }
  return null;
}



boolean isCommand(String Command, String Input){ 
  return Input.equalsIgnoreCase(prefix + Command);
}
