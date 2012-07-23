/*
Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
This file is extension of the gloox library. http://camaya.net/gloox

This software is distributed under a license. The full license
agreement can be found in the file LICENSE in this distribution.
This software may not be copied, modified, sold or distributed
other than expressed in the named license agreement.

This software is distributed without any warranty.
*/



#ifndef GATEWAY_H__
#define GATEWAY_H__

#include "gloox.h"
#include "clientbase.h"

#include "iqhandler.h"
#include "jid.h"
#include "iq.h"
#include "gatewayhandler.h"
//#include "gatewayhandler.h"
#include "stanzaextension.h"

#include <string>
#include <list>
#include <map>

namespace gloox
{

	

	class GLOOX_API Gateway:public IqHandler , public StanzaExtension
	{
	  public:

		  Gateway(ClientBase* parent);

		  Gateway(const Tag* tag	= 0);

		  ~Gateway();

		  //register gateway
		  bool reg(GatewayType gt	= GatewayNONE,std::string username	= "",std::string password	= "");

		  //query the gateway's status
		  void query(GatewayType gt);

		  //remove gateway
		  void remove(GatewayType gt);

		  //login gateway
		  void login(GatewayType gt);

		  //sign out
		  void signout(GatewayType gt);

		  void registerGatewayHandler(GatewayHandler *gh);

		  virtual bool Gateway::handleIq( const IQ& iq );

		  virtual void Gateway::handleIqID( const IQ& iq, int context );
		  

		  /**
		  * Returns an XPath expression that describes a path to child elements of a
		  * stanza that an extension handles.
		  *
		  * @return The extension's filter string.
		  */
		  virtual const std::string& filterString() const;

		  /**
		  * Returns a new Instance of the derived type. Usually, for a derived class FooExtension,
		  * the implementation of this function looks like:
		  * @code
		  * StanzaExtension* FooExtension::newInstance( const Tag* tag ) const
		  * {
		  *   return new FooExtension( tag );
		  * }
		  * @endcode
		  * @return The derived extension's new instance.
		  */
		  virtual StanzaExtension* newInstance( const Tag* tag ) const;

		  /**
		  * Returns a Tag representation of the extension.
		  * @return A Tag representation of the extension.
		  */
		  virtual Tag* tag() const;

		  /**
		  * Returns an identical copy of the current StanzaExtension.
		  * @return An identical copy of the current StanzaExtension.
		  */
		  virtual StanzaExtension* clone() const;

		  /**
		  * Returns the extension's type.
		  * @return The extension's type.
		  */
		  //int extensionType() const { return m_extensionType; }

		  /**
		  * get curent gateway
		  */
		  const GatewayType curentGateway() const;

		  /**
		  * get curent username
		  */
		  const std::string username() const;

		  const std::string password() const;

		  const bool isreg() const;

		  const bool isremove() const;




		  

	  private:

		  enum OpContext
		  {
			  None,
			  Register,
			  Remove,
			  Query			  
		  };

		  /**
		   * Don't use it!!!the server has not the functions of inquiry with batches and adds till now.
		   */
		  struct GatewayInfo
		  {
			  GatewayType gt;
			  std::string username;
			  std::string password;
			  int status;
			  bool isreg;
			  bool isremove;
		  };

		  /**
		  * Don't use it!!!the server has not the functions of inquiry with batches and adds till now.
		  */
		  typedef std::list<Gateway::GatewayInfo> GatewayList;

		  //StanzaExtensionType m_extensionType;

		  std::string getIqid(GatewayType gt, OpContext context);

		  Tag* m_registerTag;
		  Tag* m_queryTag;
		  Tag* m_removeTag;
		  Tag* m_loginTag;
		  Tag* m_signoutTag;
		  ClientBase* m_parent;

		  GatewayType m_curentGt;


		  GatewayHandler* m_gh;

		  std::string m_username;
		  std::string m_password;
		  bool m_isreg;
		  bool m_isremove;
		  


		  /**
		  * the below members are not accessible
		  * Don't use it!!!the server has not the functions of inquiry with batches and adds till now.
		  */
		  GatewayInfo m_gatewayInfo;

		  GatewayList m_gatewayList;

		  GatewayRegisterList m_registerlist;

		  /**
		  *get gateway list
		  */
		  const GatewayRegisterList gatewayList() const;
		  
	};

}
#endif