/*
Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
This file is extension of the gloox library. http://camaya.net/gloox

This software is distributed under a license. The full license
agreement can be found in the file LICENSE in this distribution.
This software may not be copied, modified, sold or distributed
other than expressed in the named license agreement.

This software is distributed without any warranty.
*/



#ifndef GATEWAYHANDLER_H__
#define GATEWAYHANDLER_H__

#include "gloox.h"
#include "gateway.h"
#include <map>



namespace gloox
{

	typedef std::map<std::string,std::pair<std::string,std::string> > GatewayRegisterList;


	class GLOOX_API GatewayHandler
	{
		
		
	  public:
		  virtual ~GatewayHandler(){}

		  virtual void HandleGatewayRegister(const GatewayType& gt)	= 0;

		  virtual void HandleGatewayQuery(const GatewayType& gt,const std::string& username)	= 0;

		  virtual void HandleGatewayRemove(const GatewayType& gt)	= 0;


	};

}
#endif