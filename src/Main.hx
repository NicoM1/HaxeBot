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

class Main 
{
	static var t:Twitter;
	static var q:Query;
	static var last:Int64;
	
	static var repeat:Timer;
	
	static function main() 
	{
		Log.trace = cleanTrace;
		
		start();
		
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
		trace("Attempting Search");
		try {
			q.setSinceId(last);
			
			var qr:QueryResult = t.search(q); 
			var haxetweets = qr.getTweets();
			
			if (haxetweets.size() > 0)
			{
				trace("Search Results:");
				
				for (h in haxetweets)
				{
					trace("\t" + h.getText());
					t.retweetStatus(h.getId());
				}
			
				last = haxetweets.get(haxetweets.size() - 1).getId();
			}
			else
			{
				trace("\tNo Results");
			}
		}
		catch (e:Dynamic) { throw e; }
	}
	
	static function cleanTrace(v:Dynamic, ?inf:PosInfos)
	{
		Sys.println(v);
	}
}