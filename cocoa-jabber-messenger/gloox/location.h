/*
Copyright (c) 2009-2011 by Haojing <haojingus@gmail.com>
This file is extension of the gloox library. http://camaya.net/gloox

This software is distributed under a license. The full license
agreement can be found in the file LICENSE in this distribution.
This software may not be copied, modified, sold or distributed
other than expressed in the named license agreement.

This software is distributed without any warranty.
*/


#ifndef LOCATION_H__
#define LOCATION_H__

#include "gloox.h"
#include "stanzaextension.h"
#include "presencehandler.h"
#include "locationhandler.h"


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
	class GLOOX_API Location : private PresenceHandler , public StanzaExtension 
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
		Location(ClientBase* parent,std::string longitude	= EmptyString, std::string latitude	= EmptyString, LocationType	type	= LocationRequest ,std::string address = EmptyString);

		/**
		* Creates a SinaVikaLocation.
		* @param tag The tag of vika.
		*/
		Location(const Tag *tag = 0);

		/**
		* Virtual destructor.
		*/
		virtual ~Location();

		/**
		 * start GPS track
		 */
		void launch();

		/**
		 * stop GPS track
		 */
		void stop();

		/**
		 * send GPS information
		 */
		void send(const JID& jid,LocationType type	= LocationRequest);

		void send(const JID& jid,std::string longitude,std::string latitude,std::string address = EmptyString);


		/**
		 * set mode of location
		 */
		void setMode(LocationType type);



		virtual void initLocation();

		/**
		* Register LocationHandler.
		*/
		void registerLocationHandler(LocationHandler *lh);

		/**
		* Remove LocationHandler.
		*/
		void removeLocationHandler();


		// reimplemented from StanzaExtension
		virtual const std::string& filterString() const
		{
			static const std::string filter = "/presence/x[@xmlns='" + XMLNS_VIKA_LOCATION + "']";
			return filter;
		}

		// reimplemented from StanzaExtension
		virtual StanzaExtension* newInstance( const Tag* tag ) const
		{
			return new Location( tag );
		}

		virtual void handlePresence( const Presence& presence );

		// reimplemented from Stanza
		Tag* tag() const;

		// reimplemented from StanzaExtension
		virtual StanzaExtension* clone() const;


		/*

		void setLongitude(std::string longitude);

		void setLatitude(std::string latitude);

		*/

		/**
		* Returns the JID of applicant
		* @return The origin of the stanza.
		*/
		JID	Jid() const;

		/**
		* Returns the longitude of location
		* @return The origin of the stanza.
		*/
		std::string	longitude();

		/**
		* Returns the latitude of location
		* @return The origin of the stanza.
		*/
		std::string	latitude();

		/**
		* Returns the address of location
		* @return The origin of the stanza.
		*/
		std::string address();

		/**
		* Returns the type of location
		* @return The origin of the stanza.
		*/
		LocationType type();

		


		private:

			ClientBase* m_parent;
			std::string m_longitude;
			std::string m_latitude;
			std::string m_address;
			LocationHandler*	m_locationhandler;
			JID m_jid;
			LocationType m_type;

			bool m_launched;

			Tag* m_tag;

			void send(const JID& jid,Location* loc);


	};
}

#endif // LOCATION_H__