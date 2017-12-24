package guestbook;

import java.util.Date;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

import com.googlecode.objectify.annotation.Entity;

import com.googlecode.objectify.annotation.Id;

import com.googlecode.objectify.annotation.Parent;

 

@Entity

public class Greeting implements Comparable<Greeting> {

    @Id Long id;
    
    @Parent Key parent;

    User user;

    String content;

    Date date;

    private Greeting() {}

    public Greeting(User user, String content, Key parent) {
    	
    	this.parent = parent;

        this.user = user;

        this.content = content;

        date = new Date();

    }

    public User getUser() {

        return user;

    }

    public String getContent() {

        return content;

    }
    
    public Date getDate() {

        return date;

    }
    
    public Key getParent() {

        return parent;

    }

    public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public void setParent(Key parent) {
		this.parent = parent;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	@Override

    public int compareTo(Greeting other) {

        if (date.after(other.date)) {

            return 1;

        } else if (date.before(other.date)) {

            return -1;

        }

        return 0;

    }

}