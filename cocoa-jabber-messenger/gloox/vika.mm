/*
  Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
  This file is extension of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/
#include "vika.h"
#include "clientbase.h"
#include "error.h"
#include "util.h"
#include "tag.h"

namespace gloox
{
	/* Sina vika value */
	static const char* vikaValues [] = {
    "",
    "group",
    "privacy",
    "finduser" 
	};

	/* Sina vika value */
	static const char* groupOpValues [] = {
    "",
    "apply",
    "invite",
    "exit" 
	};

	
	Vika::Vika(ClientBase* parent):m_parent(parent),m_vikahandler( 0 ),m_group(0)
	{
		if(m_parent)
		{
			
			m_group	= new Group();
			m_parent->registerStanzaExtension(m_group);	
			//m_parent->registerPresenceHandler(parent);
		}

	}

	Vika::~Vika()
	{
		//if(m_group)
		//	delete m_group;
	}

	void Vika::registerVikaHandler(VikaHandler *vh)
	{
		this->m_vikahandler	= vh;
		this->m_group->registerGroupHandler(vh);
	}

	void Vika::removeVikaHandler()
	{
		this->m_vikahandler	= 0;
		this->m_group->removeGroupHandler();
	}


	void Vika::handleVikaGroup(const Group* group)
	{
		if(m_vikahandler)
			m_vikahandler->handleVikaGroup(group->groupJid(),group->type(),group->applyJid(),group->reason());

	}


	Vika::Group::Group (JID& to,std::string typestring,const std::string& xmllang)
		:StanzaExtension(ExtVikaGroup),m_typestring( typestring ),m_jid( to ),m_vikahandler( 0 ),m_tag( 0 )
	{
		//构造群组操作的tag
		//Tag* m_tag	= new Tag("presence");
		
		
		return;
	}

	//完整构造
	Vika::Group::Group(const Tag* tag)
		:StanzaExtension( ExtVikaGroup ),m_vikahandler( 0 ),m_tag( 0 ),m_jid("")

	{
	
		if( !tag)
			return;

		m_tag	= const_cast<Tag *>(tag) ;

		Tag* temp_tag	= new Tag("");

		/*扩展标签不断补充中*/
		if( tag->name() == "x" && tag->xmlns() == XMLNS_VIKA_GROUP )
		{

			this->m_typestring	= (tag->hasAttribute("type"))?(tag->findAttribute("type")):"";

			this->m_jid			= (tag->parent()->hasAttribute("from"))?(tag->parent()->findAttribute("from")):"";

			this->m_masterjid	= (tag->hasAttribute("auth"))?(tag->findAttribute("auth")):"";

			if(tag->parent()->hasChild("item"))
			{
				temp_tag	= tag->parent()->findChild("item");
				m_applyjid	= (temp_tag->hasAttribute("jid"))?temp_tag->findAttribute("jid"):"";
			}

			if(tag->parent()->hasChild("reason"))
				m_reason	= tag->parent()->findChild("reason")->cdata();			


			m_type	= (VikaGroupOperation)util::lookup( m_typestring, groupOpValues );
			
		}
		return;

	}

	Vika::Group::~Group()
	{
		
	}


	StanzaExtension* Vika::Group::clone() const
	{
		Group* m	= new Group();	
		
		return m;

	}

	Tag* Vika::Group::tag() const
	{
		if(m_tag)
			return m_tag;

		if(this->m_type==VikaGroupNone)
			return 0;

		Tag* t	= new Tag("persence");
		t->setXmlns(XMLNS_VIKA_GROUP);

		return t;

		

	}

	void Vika::Group::registerGroupHandler(VikaHandler *vh)
	{
		if(vh)
			m_vikahandler	= vh;
	}

	void Vika::Group::removeGroupHandler()
	{
		m_vikahandler	= 0;
	}

	VikaGroupOperation Vika::Group::type() const
	{
		return m_type;
	}

	JID Vika::Group::groupJid() const
	{
		return m_jid;
	}

	JID Vika::Group::masterJid() const
	{
		return m_masterjid;
	}

	JID Vika::Group::applyJid() const
	{
		return m_applyjid;
	}

	std::string Vika::Group::reason() const
	{
		return m_reason;
	}


}