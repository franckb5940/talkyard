/**
 * Copyright (C) 2013 Kaj Magnus Lindberg (born 1979)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package test.e2e.code

import com.debiki.core.Prelude._
import TestSiteCreator._



object TestSiteCreator {

  /** Sometimes I don't empty the database different specs, so it's best
    * to never reuse a website id — otherwise there'll be "website already created"
    * errors.
    */
  private var nextWebsiteId = 0

}



/** Creates test sites, via /-/create-site/...
  */
trait TestSiteCreator extends TestLoginner {
  self: DebikiBrowserSpec =>

  private var knownWindowHandles = Set[String]()


  val DefaultHomepageTitle = "Default Homepage"


  def createWebsiteChooseTypePage = new Page {
    val url = s"http://$newSiteDomain/-/create-site/choose-owner"
  }


  def nextSiteName(): String = {
    nextWebsiteId += 1
    s"test-site-$nextWebsiteId"
  }


  def clickCreateSite(siteName: String = null): String = {
    val name =
      if (siteName ne null) siteName
      else nextSiteName()

    info("create site $name")

    go to createWebsiteChooseTypePage

    clickLoginWithGmailOpenId()

    clickChooseSiteTypeSimpleSite()

    click on "website-name"
    enter(name)
    click on "accepts-terms"
    click on cssSelector("input[type=submit]")

    name
  }


  def clickChooseSiteTypeSimpleSite() {
    click on id("site-type")
    click on id("new-simple-site")
    click on cssSelector("input[type=submit]")
    eventually {
      find("website-name") must be ('defined)
    }
  }


  def clickWelcomeLoginToDashboard(newSiteName: String) {
    info("click login link on welcome owner page")
    // We should now be on page /-/create-site/welcome-owner.
    // There should be only one link, which takes you to /-/admin/.
    eventually {
      assert(pageSource contains "Website created")
    }
    click on cssSelector("a")

    info("login to admin dashboard")
    clickLoginWithGmailOpenId()
    eventually {
      assert(pageSource contains "Admin Page")
    }
    webDriver.getCurrentUrl() must be === originOf(newSiteName) + "/-/admin/"
  }


  def clickLoginWithGmailOpenId(approvePermissions: Boolean = true) {
    eventually {
      click on cssSelector("a.login-link-google")
    }
    fillInGoogleCredentials(approvePermissions)
  }


  def originOf(newSiteName: String) =
    s"http://$newSiteName.$newSiteDomain"

}

