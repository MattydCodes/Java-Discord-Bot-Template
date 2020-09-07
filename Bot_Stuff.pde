import java.io.File;
import java.util.List;

JDA jda;

void initBot(OnlineStatus status,Game game){
  String token = loadStrings("data/botToken.txt")[0];
  try{
    jda = new JDABuilder(AccountType.BOT).setToken(token).build(); //Make sure NEVER to switch from BOT to CLIENT, you could get banned! discord says it's a nono now :( 
    jda.getPresence().setStatus(status);
    jda.getPresence().setGame(game);  
  }catch(Exception e){
    println("Make sure you set your token in the file" + ProjectPath + "data/botToken.txt");
    println(e); //Usually will throw an error from an incorrect token ect.. Make sure to save your bots token in the botToken.txt file under data..
  }
  jda.addEventListener(new Commands()); //Where we use the Commands class.. to attach a listener to a new instance of it.
}
