package ;

import haxe.Log;
import haxe.PosInfos;
import twitter4j.TwitterFactory;
import twitter4j.Twitter;
import twitter4j.Status;
import twitter4j.Query;
import twitter4j.QueryResult;

import haxe.Int64;
import haxe.Timer;

using StringTools;

class Main 
{
	static var t:Twitter;
	static var q:Query;
	static var last:Int64;
	
	static var repeat:Timer;
	
	static var running:Bool = true;
	
	static var owner:String = "nico_m__";
	
	static function main() 
	{
		Log.trace = cleanTrace;
		
		start();
		
		Sys.print("Attempting Search");
		search();

		repeat = new Timer(6000);
		repeat.run = search;
	}
	
	static function start()
	{	
		t = TwitterFactory.getSingleton();
		q = new Query("#haxe+exclude:retweets");
		
		try { 			
			q.setCount(1);
			
			var qr:QueryResult = t.search(q); 
			var haxetweets = qr.getTweets();
			
			last = haxetweets.get(0).getId();
		}
		catch (e:Dynamic) { throw e; }
		
		trace("INITIALIZED\n===================================");
	}
	
	static function search()
	{
		try 
		{
			if (running)
			{
				Sys.print(" |");
			}
			q.setSinceId(last);
			
			var qr:QueryResult = t.search(q); 
			var haxetweets = qr.getTweets();
			
			if (haxetweets.size() > 0)
			{
				trace("\nSearch Results:");
				
				for (h in haxetweets)
				{
					#if !debug
						if (checkShutdown(h))
						{
							break;
						}
						else if (!running)
						{
							running = true;
							break;
						}
					#end
					
					trace("\t" + "@" + h.getUser().getScreenName() + ": " + h.getText());
					t.retweetStatus(h.getId());
				}
			
				last = haxetweets.get(haxetweets.size() - 1).getId();
			}
		}
		catch (e:Dynamic) { throw e; }
	}
	
	static function checkShutdown(h:Status):Bool
	{
		try {
			if (running)
			{
				if (h.getUser().getScreenName() == owner)
				{
					if (h.getText().indexOf("SHUTDOWN") > -1) 
					{
						if (h.getText().indexOf("@haxebot") > -1)
						{
							running = false;
							trace("\nSHUTDOWN by @" + owner);
							return true;
						}
					}
				}
			}
			else
			{
				if (h.getUser().getScreenName() == owner)
				{
					if (h.getText().indexOf("BOOT") > -1 )
					{
						if (h.getText().indexOf("@haxebot") > -1)
						{
							trace("\nREBOOTED by @" + owner);
							Sys.print("Attempting Search");
							return false;
						}
					}
				}
				return true;
			}
		}
		catch (e:Dynamic) { throw e; }
		return false;
	}
	
	static function cleanTrace(v:Dynamic, ?inf:PosInfos)
	{
		Sys.println(v);
	}
}