// Working Objectify URL: http://guestbook.spenceryue.me/ofyguestbook.jsp
// Original (No Objectify) URL: http://guestbook.spenceryue.me

package guestbook;



import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;

import com.google.appengine.api.users.User;

import com.google.appengine.api.users.UserService;

import com.google.appengine.api.users.UserServiceFactory;

import com.google.appengine.api.datastore.Key;

import com.google.appengine.api.datastore.KeyFactory;

 

import java.io.IOException;
 

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class OfySignGuestbookServlet extends HttpServlet {
	

	static {
	
	        ObjectifyService.register(Greeting.class);
	
	    }

    public void doPost(HttpServletRequest req, HttpServletResponse resp)

                throws IOException {

        UserService userService = UserServiceFactory.getUserService();

        User user = userService.getCurrentUser();

        // We have one entity group per Guestbook with all Greetings residing

        // in the same entity group as the Guestbook to which they belong.

        // This lets us run a transactional ancestor query to retrieve all

        // Greetings for a given Guestbook.  However, the write rate to each

        // Guestbook should be limited to ~1/second.

        String guestbookName = req.getParameter("guestbookName");

        Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);

        String content = req.getParameter("content");

        Greeting greeting = new Greeting(user, content, guestbookKey);
 
        ofy().save().entity(greeting).now();
 

        resp.sendRedirect("/ofyguestbook.jsp?guestbookName=" + guestbookName);

    }

}