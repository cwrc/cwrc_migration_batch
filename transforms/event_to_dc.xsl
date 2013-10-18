<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
  >

  <!--
  * given an Orlando event - output a DC format datastream
  * designed to work with 1 event per file
  *
  * 2013-10-18 - not used - Orlando events have MODS and used to create DC title
  * as opposed to CWRC-Content
  -->

  <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no" />


  <!--
  * PID value passed into the transform 
  -->
  <xsl:param name="PID_PARAM" select="'zzzz'"/>


  <!--
  * build DC
  -->
  <xsl:template match=" /FREESTANDING | /EMBEDDED">
    <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" >
      <dc:title>
        <xsl:call-template name="GET_DC_TITLE" />
      </dc:title>
      <dc:identifier>
        <xsl:value-of select="$PID_PARAM" />
      </dc:identifier>
    </oai_dc:dc> 
  </xsl:template>


  <!--
  * select the appropriate DC title template
  -->
  <xsl:template name="GET_DC_TITLE">
   <xsl:apply-templates select="CHRONPROSE" mode="event_dc_title" />
  </xsl:template>

</xsl:stylesheet>
