/*
  Copyright (c) 2006-2009 by Jakob Schroeter <js@camaya.net>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/

#include "location.h"
#include "locationhandler.h"
#include "clientbase.h"
#include "error.h"
#include "util.h"
#include "tag.h"
#include "presence.h"

namespace gloox
{

	/* Sina vika value */
	static const char* locationTypeValues [] = {
		"",
		"request",
		"response",
		"stop"
	};



	Location::Location(ClientBase* parent,std::string longitude, std::string latitude, LocationType type, std::string address)
		:StanzaExtension(ExtVikaLocation),m_latitude( latitude ),
		m_longitude( longitude ), m_launched( false ),
		m_locationhandler( 0 ), m_parent( parent ),
		m_type( type ), m_address(address)
	{
		//	this->initLocation();
		if(!parent)
			return;

		m_parent->registerStanzaExtension(this);
	}

	Location::Location(const Tag *tag /* = 0 */):StanzaExtension(ExtVikaLocation),m_parent( 0 ),m_locationhandler( 0 )
	{
		if( !tag)
		{
			m_type	= LocationRequest;
			return;
		}

		m_tag	= const_cast<Tag *>(tag) ;

		if( tag->name() == "x" && tag->xmlns() == XMLNS_VIKA_LOCATION )
		{
			//m_jid			= (tag->parent()->hasAttribute("from"))?(tag->parent()->findAttribute("from")):"";
			m_type	= (LocationType)util::lookup((tag->hasAttribute("type"))?(tag->findAttribute("type")):"",locationTypeValues);
			m_latitude	= (tag->hasAttribute("mapy"))?(tag->findAttribute("mapy")):"0";
			m_longitude	= (tag->hasAttribute("mapx"))?(tag->findAttribute("mapx")):"0";
			m_address	= (tag->hasAttribute("address"))?(tag->findAttribute("address")):EmptyString;
		}
		return;
	}

	Location::~Location()
	{
		if(m_parent)
		{
			stop();
		}


	}

	void Location::handlePresence( const Presence& presence )
	{
		if(!m_locationhandler)
			return;
		Location* l = const_cast<Location*>( presence.findExtension<Location>( ExtVikaLocation ));
		if(!l)
			return;

		if(l->type() == LocationRequest)
			m_locationhandler->handleLocationRequest(presence.from());

		if(l->type() == LocationStopResponse)
			m_locationhandler->handleLocationStopResponse(presence.from());

		if(l->type() == LocationResponse)
			m_locationhandler->handleLocationResponse(presence.from(),
			l->longitude(),
			l->latitude(),
			l->address()
			);
	}

	StanzaExtension* Location::clone() const
	{
		Location*	m = new Location(tag());
		return m;
	}

	Tag* Location::tag() const
	{
		Tag* t	= new Tag("x");
		t->setXmlns(XMLNS_VIKA_LOCATION);
		t->addAttribute("type",util::lookup(m_type,locationTypeValues));
		if(m_type==LocationResponse)
		{
			t->addAttribute("mapx",m_longitude);
			t->addAttribute("mapy",m_latitude);
			t->addAttribute("address",m_address);
		}
		return t;
	}

	void Location::registerLocationHandler(LocationHandler *lh)
	{
		if(lh)
			m_locationhandler	= lh;
	}

	void Location::removeLocationHandler()
	{
		m_locationhandler	= 0;
	}

	void Location::send(const JID& jid,Location* loc)
	{
		Presence pres(Presence::Available,jid);
		pres.addExtension(loc);
		m_parent->send(pres,false);

	}

	void Location::send(const JID& jid,LocationType type)
	{
		if(type	== LocationResponse)
			return;
		Location* m_loc	= new Location(0,"","",type);
		send(jid,m_loc);
	}



	void Location::send(const JID& jid,std::string longitude,std::string latitude,std::string address)
	{
		if(longitude==""||latitude=="")
			return;
		Location* m_loc	= new Location(0,longitude,latitude,LocationResponse,address);
		send(jid,m_loc);
	}

	void Location::setMode(LocationType type)
	{
		m_type	= type;
	}

	/*
	void Location::setLongitude(std::string longitude)
	{
		m_longitude	= longitude;

	}

	void Location::setLatitude(std::string latitude)
	{
		m_latitude	= latitude;
	}
	*/

	std::string Location::address() 
	{
		return m_address;
	}

	JID Location::Jid() const
	{
		return m_jid;
	}

	std::string Location::latitude()
	{
		return m_latitude;
	}

	std::string Location::longitude()
	{
		return m_longitude;
	}

	LocationType Location::type()
	{
		return m_type;
	}

	void Location::initLocation()
	{
		return;
	}

	
	void Location::launch()
	{
		if(!m_parent||m_launched)
			return;
		m_parent->registerPresenceHandler(this);
		m_launched	= true;

	}
	

	void Location::stop()
	{
		if(!m_launched)
			return;
		if(m_parent)
		{
			m_parent->removePresenceHandler(this);

		}
		m_launched	= false;

	}

}