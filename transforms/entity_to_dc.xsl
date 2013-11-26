<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
  >

  <!--
  * JCA
  * Mon 30-Sep-2013
  * given a CWRC entity - person, organization, or title - output a DC format datastream
  * designed to work with 1 entity per file
  -->

  <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no" />


  <!--
  * PID value passed into the transform 
  -->
  <xsl:param name="PID_PARAM" select="'zzzz'"/>


  <!--
  * build DC
  -->
  <xsl:template match="/cwrc/entity | /entity | /mods:modsCollection/mods:mods | /mods:mods">
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
   <xsl:apply-templates select="person | organization | mods:titleInfo" mode="entity_dc_title" />
  </xsl:template>


  <!--
  * build the DC title - person entity
  * privelege identity/displayLabel
  * over the identity/preferredForm/namePart[@partType="forename"] concatenated with the identity/preferredForm/namePart[@partType="surname"]
  * over the identity/preferredForm/namePart
  -->
  <xsl:template match="person" mode="entity_dc_title">
    <!-- does a surname exist -->
    <xsl:variable name="is_surname_present" select="identity/preferredForm/namePart/@partType='surname'" />
    <!-- does a forename exist -->
    <xsl:variable name="is_forename_present" select="identity/preferredForm/namePart/@partType='forename'" />
            
    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="normalize-space(identity/displayLabel)" />
      </xsl:when>
      <!-- surname and forename -->
      <xsl:when test="$is_surname_present or $is_forename_present">
        <xsl:if test="$is_forename_present">
          <xsl:value-of select="normalize-space(identity/preferredForm/namePart[@partType='forename']/text())" />
        </xsl:if>
        <xsl:if test="$is_forename_present and $is_surname_present">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="$is_surname_present">
          <xsl:value-of select="normalize-space(identity/preferredForm/namePart[@partType='surname']/text())" />
        </xsl:if>
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="normalize-space(identity/preferredForm/namePart)" />
      </xsl:when>
      <xsl:otherwise> 
          <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>


  <!--
  * build the DC title - organization entity
  * privelege identity/displayLabel over the identity/preferredForm/namePart
  * Note: all organization entities appear to use the <namePart> element for the organization name, with no organization entities using the <displayLabel> element
  -->
 <xsl:template  match="organization" mode="entity_dc_title">

    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="normalize-space(identity/displayLabel)" />
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="normalize-space(identity/preferredForm/namePart)" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>


  <!--
  * build the DC title - Title entity
  * All information for title will come from the following XPath in each MODS record: /mods/titleInfo/title
  * 
  -->
 <xsl:template match="mods:titleInfo" mode="entity_dc_title">
    <xsl:choose>
      <xsl:when test="not(@type) and mods:title">
        <xsl:value-of select="normalize-space(mods:title)"/>
      </xsl:when>
      <xsl:when test="not(@type) and @usage='primary' and mods:title ">
        <xsl:value-of select="normalize-space(mods:title)"/>
      </xsl:when>
     <xsl:when test="@type='alternative' or @type='abbreviated' or @type='translated' or @type='uniform'">
        <!-- multiple titles, don't use type='alternative' -->
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
