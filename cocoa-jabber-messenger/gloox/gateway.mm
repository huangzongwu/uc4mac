/*
Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
This file is extension of the gloox library. http://camaya.net/gloox

This software is distributed under a license. The full license
agreement can be found in the file LICENSE in this distribution.
This software may not be copied, modified, sold or distributed
other than expressed in the named license agreement.

This software is distributed without any warranty.
*/

#include "gateway.h"
#include "clientbase.h"
#include "error.h"
#include "util.h"
#include "tag.h"
#include "presence.h"

#include "registration.h"



namespace gloox
{
	/* gateway value */
	static const char* gatewayDomainValues [] = {
		"",
		"msn.uc.sina.com.cn",
		"weibo.uc.sina.com.cn",
		"gtalk.uc.sina.com.cn" ,
		"yahoo.uc.sina.com.cn"
	};

	Gateway::Gateway(ClientBase* parent):StanzaExtension(ExtGateway),m_parent( parent ),m_gh( 0 )
	{
		if(parent)
		{
			m_parent->registerIqHandler(this,ExtGateway);
			m_parent->registerStanzaExtension(this);
			
		}
	}

	Gateway::Gateway(const Tag* tag /* = 0 */):StanzaExtension(ExtGateway),
		m_parent( 0 ), m_gh( 0 ), m_isreg( false ),
		m_isremove( false ), m_username( "" ), m_password( "" )
	{
		if(!tag)
			return;
		if(tag->name()=="iq"&&tag->hasAttribute("from"))
		{
			int m_index	= util::lookup(tag->findAttribute("from"),gatewayDomainValues);

			if(m_index>0)
			{

				m_curentGt	= (GatewayType)m_index;
				m_isreg		= (tag->findAttribute("id").find("register")!=std::string::npos);

				m_isremove	= (tag->findAttribute("id").find("remove")!=std::string::npos);


				if(tag->hasChild("query"))
				{
					m_isreg	= tag->findChild("query")->hasChild("registered");
					
					m_username	= (tag->findChild("query")->hasChild("username"))?tag->findChild("query")->findChild("username")->cdata():"";
					m_password	= (tag->findChild("query")->hasChild("password"))?tag->findChild("query")->findChild("password")->cdata():"";

				}


				//m_gatewayList.push_back(m_gatewayInfo);

			}
		}
	}

	Gateway::~Gateway()
	{
		if(m_parent)
		{
			m_parent->removeIqHandler(this,ExtGateway);
		}
	}

	bool Gateway::reg(GatewayType gt /* = GatewayNONE */,std::string username /* =  */,std::string password /* = */ )
	{
		if(!m_parent)
			return false;
		m_curentGt	= gt;
		m_username	= username;
		m_password	= password;

		RegistrationFields m_field;
		m_field.username	= username;
		m_field.password	= password;
		Registration::Query* m_regQuery = new Registration::Query(Registration::FieldUsername|Registration::FieldPassword,m_field);

		IQ m_iq(IQ::Set,util::lookup((int)gt , gatewayDomainValues ),getIqid(gt,Register));
		m_iq.addExtension( m_regQuery );
		m_parent->send(m_iq,this,Register);
		return true;

	}

	void Gateway::query(GatewayType gt)
	{
		if(!m_parent)
			return;
		std::string m_domain	= util::lookup((int)gt , gatewayDomainValues );
		IQ m_iq(IQ::Get,m_domain,getIqid(gt,Query));

		RegistrationFields m_field;
		Registration::Query* m_regQuery = new Registration::Query(0,m_field);
		m_iq.addExtension(m_regQuery);

		m_parent->send(m_iq,this,Query);
	}

	void Gateway::remove(GatewayType gt)
	{
		if(!m_parent)
			return;
		std::string m_domain	= util::lookup((int)gt , gatewayDomainValues );
		IQ m_iq(IQ::Set,m_domain,getIqid(gt,Remove));

		m_iq.addExtension(new Registration::Query(true));

		m_parent->send(m_iq,this,Remove);

	}

	void Gateway::login(GatewayType gt)
	{
		Tag* tag	= new Tag("presence");
		tag->addAttribute("id",getIqid(gt,None));
		tag->addAttribute("to",util::lookup((int)gt , gatewayDomainValues ));

		m_parent->send(tag);
		//delete tag;
	}

	void Gateway::signout(GatewayType gt)
	{
		Tag* tag	= new Tag("presence");
		tag->addAttribute("id",getIqid(gt,None));
		tag->addAttribute("to",util::lookup((int)gt , gatewayDomainValues ));
		tag->addAttribute("from",m_parent->jid().bare());
		tag->addAttribute("type","unavailable");

		m_parent->send(tag);
		//delete tag;
	}

	std::string Gateway::getIqid(GatewayType gt, OpContext context)
	{
		std::string m_string	= "";
		if(m_parent)
		{
			m_string	= m_parent->jid().username();
			switch (context)
			{
			  case Register:
				  m_string	+=	":register";
				  break;
			  case Remove:
				  m_string	+=	":remove";
				  break;
			  case Query:
				  m_string	+=	":query";
				  break;
			  default:
				  m_string	+=	":gateway";
				  break;
			}
		}
		char m_gtmp[2];
		sprintf(m_gtmp,"%d",gt);
		m_string	+=	m_gtmp;

		return m_string;

	}

	bool Gateway::handleIq( const IQ& iq )
	{
		return true;

	}

	void Gateway::handleIqID( const IQ& iq, int context )
	{
		if(!m_parent||!m_gh)
			return;

		const Gateway* m	= iq.findExtension<Gateway>(ExtGateway);

		if(iq.id().find("register")!=std::string::npos)
		{
			m_gh->HandleGatewayRegister(m->curentGateway());
			

		}
		else if(iq.id().find("remove")!=std::string::npos)
		{
			m_gh->HandleGatewayRemove(m->curentGateway());
		}
		else if(iq.id().find("query")!=std::string::npos)
		{

			m_gh->HandleGatewayQuery(m->curentGateway(),m->username());			

		}

			
			//m_gh->HandleRegister()

	}

	void Gateway::registerGatewayHandler(GatewayHandler *gh)
	{
		if(gh)
			this->m_gh	= gh;
	}



	const std::string& Gateway::filterString() const
	{
		static const std::string filter = 
			"/iq[@from='msn.uc.sina.com.cn']"
			"|/iq[@from='weibo.uc.sina.com.cn']"
			"|/iq[@from='gtalk.uc.sina.com.cn']"
			"|/iq[@from='yahoo.uc.sina.com.cn']";

		return filter;
	}

	StanzaExtension* Gateway::newInstance( const Tag* tag ) const
	{
		return new Gateway(tag);
	}

	Tag* Gateway::tag() const
	{

		/**
		GatewayList::const_iterator ite = m_gatewayList.begin();
		for( ; ite != m_gatewayList.end(); ++ite )
		{
		(*ite)->gt;
		}
		**/
		return 0;

	}

	StanzaExtension* Gateway::clone() const
	{
		Gateway* m	= new Gateway(this->tag());
		return m;
	}


	const GatewayType Gateway::curentGateway() const
	{
		return m_curentGt;
	}

	const GatewayRegisterList Gateway::gatewayList() const
	{

		return m_registerlist;
	}

	const std::string Gateway::username() const
	{
		return m_username;
	}

	const std::string Gateway::password() const
	{
		return m_password;
	}

	const bool Gateway::isreg() const
	{
		return m_isreg;
	}

	const bool Gateway::isremove() const
	{
		return m_isremove;
	}





}