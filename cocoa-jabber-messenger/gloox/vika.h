/*
Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
This file is extension of the gloox library. http://camaya.net/gloox

This software is distributed under a license. The full license
agreement can be found in the file LICENSE in this distribution.
This software may not be copied, modified, sold or distributed
other than expressed in the named license agreement.

This software is distributed without any warranty.
*/


#ifndef VIKA_H__
#define VIKA_H__

#include "gloox.h"
#include "stanzaextension.h"
#include "vikahandler.h"
#include "presence.h"

#include <string>
#include <utility>

namespace gloox
{
	class JID;
	class ClientBase;
	class Tag;

	/**
	* @brief This is not an implementation of XEP,but this is a private expansion which is similar to XEP.
	*
	* Usage is pretty simple:
	*
	* Derrive an object from VikaHandler and implement its virtuals:
	* @code
	* class MyClass : public VikaHandler
	* {
	*   ...
	* };
	* @endcode
	*
	* While establishing Client samples, Vika minitoring will be activated throuth Clientbase. 
	* Currently we finished the vika status of Group which is named callback, and in future 
	* we will add more other properties, like black list, on line searching etc
	*
	*
	*
	* XEP version: none
	* @author Hao Jing <haojingus@gmail.com>
	* @since 1.0
	*/
	class GLOOX_API Vika
	{
		

	public:

		/**
		* @brief An abstraction of a Vika group.
		*
		* You should not need to use this class directly.
		*
		* @author Hao Jing <haojingus@gmail.com>
		* @since 1.0
		*/
		Vika(ClientBase* parent);

		/**
		* Virtual destructor.
		*/
		virtual ~Vika();

		

		/**
		* Register VikaHandler.
		*/
		void registerVikaHandler(VikaHandler *vh);

		/**
		* Remove VikaHandler.
		*/
		void removeVikaHandler();



		/**
		* @brief An abstraction of a group presence.
		*
		* You should not need to use this class directly.
		*
		* @author Hao jing <haojingus@gmail.com>
		* @since 1.0
		*/
		class GLOOX_API Group:public StanzaExtension
		{
		public:

			/**
			* Creates a SinaVika.
			* @param tagname The tag's name.
			* @param type is the type of vika.
			* @param xmllang An optional xml:lang for the status message.
			*/
			Group(JID& to,std::string typestring,const std::string& xmllang = EmptyString);


			/**
			* Creates a SinaVikaGroup.
			* @param tag The tag of vika.
			*/
			Group(const Tag *tag = 0);

			/**
			* Virtual destructor.
			*/
			virtual ~Group();

			/**
			* Registers @c vh as object that receives all vika tag of the specified type.
			* @param vh The object to receive exchanged data.
			*/
			void registerGroupHandler( VikaHandler* vh );

			/**
			* Remove @c vh as object that receives all vika tag of the specified type.
			*/
			void removeGroupHandler();

			// reimplemented from StanzaExtension
			virtual const std::string& filterString() const
			{
				static const std::string filter = "/presence/x[@xmlns='" + XMLNS_VIKA_GROUP + "']";
				return filter;
			}

			// reimplemented from StanzaExtension
			virtual StanzaExtension* newInstance( const Tag* tag ) const
			{
				return new Group(tag );
			}

			// reimplemented from Stanza
			Tag* tag() const;

			// reimplemented from StanzaExtension
			virtual StanzaExtension* clone() const;

			/**
			* Returns the type fo VikaGroupOperation.
			* @return The value of the enum.
			*/
			VikaGroupOperation type() const;

			/**
			* Returns the JID the stanza comes from.
			* @return The origin of the stanza.
			*/
			JID	groupJid() const;

			/**
			* Returns the JID of the group master.
			* @return The origin of the stanza.
			*/
			JID	masterJid() const;

			/**
			* Returns the JID of applicant
			* @return The origin of the stanza.
			*/
			JID	applyJid() const;

			/**
			* Returns the reason of joining.
			* @return The string of the reason.
			*/
			std::string reason() const;

			

		private:
			std::string m_typestring;
			VikaGroupOperation m_type;
			VikaHandler*	m_vikahandler;
			JID m_jid;
			std::string m_reason;
			JID m_masterjid;
			JID m_applyjid;
			Tag* m_tag;



		};

		// reimplemented from VikaHandler
		virtual void handleVikaGroup(const Group* group);



	private:


		Group *m_group;
		VikaType m_type;
		ClientBase* m_parent;
		VikaHandler* m_vikahandler;

	};
}

#endif // VIKA_H__