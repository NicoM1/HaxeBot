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
	
	static var searchQuery:String = "#haxe OR openfl OR #openfl OR @haxelang OR @FlambeGames -from:@haxe -to:@haxe -RT";
	
	static var repeat:Timer;
	
	static var running:Bool = true;
	
	static var owner:String = "nico_m__";
	
	static var pollDelay:Int = 12000;
	
	static function main() 
	{
		Log.trace = cleanTrace;
		
		start();
		
		Sys.print("Attempting Search");
		search();

		repeat = new Timer(pollDelay);
		repeat.run = search;
	}
	
	static function start()
	{	
		t = TwitterFactory.getSingleton();
		q = new Query(searchQuery);
		
		resetLast();
		
		trace("INITIALIZED\n===================================");
	}
	
	static function resetLast()
	{
		try { 			
			q.setCount(1);
			
			var qr:QueryResult = t.search(q); 
			var haxetweets = qr.getTweets();
			
			last = haxetweets.get(0).getId();
		}
		catch (e:Dynamic) { throw e; }
		
		q.setCount(10);
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
				
				var i = haxetweets.size()-1;
				
				while(i >= 0)
				{
					var h = haxetweets.get(i);
					
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
					
					i--;
				}
			
				last = haxetweets.get(0).getId();
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