<%@page import="guestbook.Greeting"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<%@ page import="java.util.List"%>

<%@page import="java.util.Collections"%>

<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.TimeZone"%>

<%@ page import="com.google.appengine.api.users.User"%>

<%@ page import="com.google.appengine.api.users.UserService"%>

<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>

<%@ page import="com.googlecode.objectify.Objectify" %>

<%@ page import="com.googlecode.objectify.ObjectifyService" %>

<%@ page import="com.google.appengine.api.datastore.Key"%>

<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
    String guestbookName = request.getParameter("guestbookName");

    if (guestbookName == null) {
        guestbookName = "default";
    }

    pageContext.setAttribute("guestbookName", guestbookName);
%>

<html>

	<head>
        <title>Guestbook: ${fn:escapeXml(guestbookName)}</title>
        <link href="https://fonts.googleapis.com/css?family=Indie+Flower|Raleway:400,800" rel="stylesheet">
        <link rel="icon" href="favicon.ico">
        <link type="text/css" rel="stylesheet" href="stylesheets/main.css">

        <!-- Loads the page and unloads the page softly -->
        <script type="text/javascript">
            function show() {
                document.getElementById('loading').style.opacity = 1;
                // <!-- Scrolls Messages to most recent (bottom) -->
                document.getElementById("Messages").scrollTop = 10000;
            }
            window.addEventListener("beforeunload", 
                function () {
                    document.getElementById('loading').style.opacity = .2;
                }
                );
        </script>

       <!-- Resizes guestbookName to fit length of placeholder name -->
        <script type="text/javascript">
            //creates a global Javascript variable
            var inputTextValue;
            
            function initLength() {
                var input = document.querySelector('input.book');
                input.setAttribute('size', input.getAttribute('placeholder').length);
            }

            // function updateLength() {
            //     var input = document.querySelector('input.book');
            //     if (input.getAttribute('value') != null) {
            //         input.setAttribute('size', input.getAttribute('value').length);
            //     }
            // }

            function updateLength(e) {
                var input = document.querySelector('input.book');
                inputTextValue = e.target.value;
                if (inputTextValue != null) {
                    input.setAttribute('size', Math.max(inputTextValue.length,
                                                        input.getAttribute('placeholder').length));
                }
            }
        </script>

        <!-- Detects Enter vs. Shift+Enter for textarea -->
        <script type="text/javascript">
            function textAreaSubmitter(event) {
                    if (event.which == 13 && !event.shiftKey) {
                     document.greeting.submit(); //Submit your form here
                     return true;
                     }
            }
        </script>
        
    </head>

<body id="loading" onload="show()">
	<section>
		<div class="row">

<%
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();

    if (user != null) {
      pageContext.setAttribute("user", user);
%>
			<h1>Hello, ${fn:escapeXml(user.nickname)}!</h1>
		</div>
		<%
    } else {
%>
			<h1>Hello!</h1>
		</div>
		<%
    }
%>

		<%

    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    
	ObjectifyService.register(Greeting.class);
	List<Greeting> greetings = ObjectifyService.ofy().load().type(Greeting.class).ancestor(guestbookKey).list();   	
	Collections.sort(greetings); 
    
    DateFormat[] dateFormat = {
    		new SimpleDateFormat("s 'seconds'\n'ago'"),	// <60000
    		new SimpleDateFormat("m 'minute'\n'ago'"),		// <12000
    		new SimpleDateFormat("m 'minutes'\n'ago'"),	// <3600000
    		new SimpleDateFormat("k 'hour'\n'ago'"),		// <7200000
    		new SimpleDateFormat("k 'hours'\n'ago'"),		// <86400000
    		new SimpleDateFormat("EEE'\n'h:mm a"),			// <604800000
    		new SimpleDateFormat("M/d/YYYY'\n'h:mm a")
    		};
    
    TimeZone original = TimeZone.getDefault();
    
    if (greetings == null || greetings.isEmpty()) {
        %>
        <div id="bookInfo">
			<form name="form" id="bookForm" method="post" action="http://guestbook.spenceryue.me/">
				<label for="book">Guestbook: </label>
				<input name="guestbookName" id="book" class="book" type="text" minlength="1" placeholder="${fn:escapeXml(guestbookName)}" onUnfocus="document.guestbookName('form').submit()" required>
				<label> has no messages.</label>
			</form>
			
			<a class="signin" href="<%= userService.createLoginURL(request.getRequestURI()) %>">sign in with <span class="nobreak"><img src="google-icon.svg">oogle</span></a>
		</div>
		
		<script type="text/javascript">
            initLength();
            //creates a listener for when you press a key
            document.querySelector('input.book').onkeyup = updateLength;
        </script>
	</section>
	<section></section>
	<%
    } else {
        %>
        <div id="bookInfo">
			<form name="form" id="bookForm" method="post" action="http://guestbook.spenceryue.me/">
				<label for="book">Messages in Guestbook: </label>
				<input name="guestbookName" id="book" class="book" type="text" minlength="1" placeholder="${fn:escapeXml(guestbookName)}" onUnfocus="document.guestbookName('form').submit()" required>
			</form>
		
		<%if (user == null) {%>
			<a class="signin" href="<%= userService.createLoginURL(request.getRequestURI()) %>">sign in with <span class="nobreak"><img src="google-icon.svg">oogle</span></a>
		<%} else {%>
			<a class="signout" href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>
		<%} %>
		</div>
			
		<script type="text/javascript">
            initLength();
            //creates a listener for when you press a key
            document.querySelector('input.book').onkeyup = updateLength;
        </script>
	</section>

	<section id="Messages">
		<%
        for (Greeting greeting : greetings) {
        	
            if (greeting.getUser() == null) {
                %>
		<div class="message">
			<p class="anonymous">a Anonymous</p>
			<%
            } else {
                pageContext.setAttribute("greeting_user",
                                         greeting.getUser());
                String firstLetter = ((String) ((greeting.getUser()).getNickname())).substring(0,1);
                pageContext.setAttribute("greeting_user_firstLetter", firstLetter);
                %>
		<div class="message">
			<p class="user">${fn:escapeXml(greeting_user_firstLetter)}
				${fn:escapeXml(greeting_user.nickname)}</p>
				<%
            }
            
            long elapsed = System.currentTimeMillis() - ((Date) (greeting.getDate())).getTime();
            int index = -1;
            //String debugg = Long.toString(elapsed);
            
	        if (elapsed >= 10000) // 10 seconds
	        	index = 0;
	        if (elapsed >= 60000) // 1 minute
	        	index = 1;
	        if (elapsed >= 120000) // 2 minutes
	        	index = 2;
	        if (elapsed >= 3600000) // 1 hour
	        	index = 3;
	        if (elapsed >= 7200000) // 2 hours
	        	index = 4;
	        if (elapsed >= 86400000) // 24 hours
	        	index = 5;
	        if (elapsed >= 604800000) // 1 week
	        	index = 6;
			
            //String debug2 = Integer.toString(index);
	        if (index == -1)
	        	pageContext.setAttribute("greeting_date", "Just now");
	        else if (index >= 5) {
	        	TimeZone.setDefault(original);
	        	pageContext.setAttribute("greeting_date", dateFormat[index].format(((Date) (greeting.getDate())).getTime()));//+" "+debugg+" "+debug2);
	        } else {
	        	TimeZone.setDefault(TimeZone.getTimeZone("GMT"));
        		pageContext.setAttribute("greeting_date", dateFormat[index].format(new Date(elapsed)));
	        }
            
		%>	<p class="content"><%pageContext.setAttribute("greeting_content", greeting.getContent());
			%>${fn:escapeXml(greeting_content)}</p>
			<p class="date">${fn:escapeXml(greeting_date)}</p>
		</div>
			<%
        }
        %>
		
	</section>
	<%
    }
%>
	<section>
            <form name="greeting" action="/ofysign" method="post">
                <textarea id="box" name="content" rows="2" placeholder="" onkeypress="textAreaSubmitter(event)"></textarea>
                <input type="submit" value="Post Greeting">
                <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}">
            </form>
        </section>
</body>

</html>