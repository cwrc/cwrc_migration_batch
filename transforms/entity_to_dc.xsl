<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="2.0"
  >

  <!--
  * JCA
  * Mon 30-Sep-2013
  * given a CWRC entity - person, organization, or title - output a DC format datastream
  -->

  <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no" />


  <!--
  * PID value passed into the transform 
  -->
  <xsl:param name="PID_PARAM" select="'zzzz'"/>


  <!--
  * build DC
  -->
  <xsl:template match="/cwrc/entity | /mods:modsCollection/mods:mods">
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

    <xsl:choose>
      <xsl:when test="entity/person">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_PERSON" />
      </xsl:when>
      <xsl:when test="entity/organization">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_ORGANIZATION" />
      </xsl:when>
      <xsl:when test="mods:mods">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_TITLE" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown Type</xsl:text>
      </xsl:otherwise >
    </xsl:choose>

  </xsl:template>


  <!--
  * build the DC title - person entity
  * privelege identity/displayLabel
  * over the identity/preferredForm/namePart[@partType="forename"] concatenated with the identity/preferredForm/namePart[@partType="surname"]
  * over the identity/preferredForm/namePart
  -->
  <xsl:template name="GET_DC_TITLE-ENTITY_PERSON">

    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="identity/displayLabel" />
      </xsl:when>
      <!-- surname and forename -->
      <xsl:when test="identity/preferredForm/namePart/@surname or identity/preferredForm/namePart/@forename">
        <xsl:if test="identity/preferredForm/namePart/@surname">
          <xsl:value-of select="identity/preferredForm/namePart[partType='surname']" />
        </xsl:if>
        <xsl:if test="identity/preferredForm/namePart/@surname and identity/preferredForm/namePart/@forename">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="identity/preferredForm/namePart/@forename">
          <xsl:value-of select="identity/preferredForm/namePart[type='forename']" />
        </xsl:if>
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="identity/preferredForm/namePart" />
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
  <xsl:template name="GET_DC_TITLE-ENTITY_ORGANIZATION">

    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="identity/displayLabel" />
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="identity/preferredForm/namePart" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>


  <!--
  * build the DC title - Title entity
  -->
  <xsl:template name="GET_DC_TITLE-ENTITY_TITLE">
    <xsl:value-of select="mods:titleInfo/mods:title"/>
  </xsl:template>

</xsl:stylesheet>
