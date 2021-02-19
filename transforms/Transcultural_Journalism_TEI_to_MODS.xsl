<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs"
  version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>


  <xsl:template match="*[not(*) and not(text()[normalize-space()])]"/>

  <xsl:template match="/">
    <mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
      xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd">
      <titleInfo>
        <title>
          <xsl:value-of select="//tei:titleStmt/tei:title//text()"/>
        </title>
      </titleInfo>
      <xsl:if test="//tei:titleStmt/tei:author/tei:persName">
        <name type="personal">
          <namePart>
            <xsl:if test="//tei:titleStmt/tei:author/tei:persName/@ref">
              <xsl:attribute name="valueURI">
                <xsl:value-of select="//tei:titleStmt/tei:author/tei:persName/@ref"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="//tei:titleStmt/tei:author/tei:persName/text()"/>
          </namePart>
          <role>
            <roleTerm authority="marcrelator" type="text">Reviewer</roleTerm>
          </role>
        </name>
      </xsl:if>
      <typeOfResource>text</typeOfResource>
      <genre>journal article</genre>
      <language>
        <languageTerm type="text">Italian</languageTerm>
      </language>
      <language>
        <languageTerm type="text">English</languageTerm>
      </language>
      <physicalDescription>
        <form authority="marccategory">text</form>
        <internetMediaType>text/xml</internetMediaType>
      </physicalDescription>
      <subject>
        <titleInfo>
          <xsl:if test="//tei:titleStmt/tei:title/tei:title/@ref">
            <xsl:attribute name="valueURI">
              <xsl:value-of select="//tei:titleStmt/tei:title/tei:title/@ref"/>
            </xsl:attribute>
          </xsl:if>
          <title>
            <xsl:value-of select="//tei:titleStmt/tei:title/tei:title/text()"/>
          </title>
        </titleInfo>
      </subject>
      <xsl:if test="//tei:notesStmt/tei:relatedItem">
        <subject>
          <titleInfo>
            <xsl:if test="//tei:notesStmt/tei:relatedItem/tei:bibl/tei:title/@ref">
              <xsl:attribute name="valueURI">
                <xsl:value-of select="//tei:notesStmt/tei:relatedItem/tei:bibl/tei:title/@ref"/>
              </xsl:attribute>
            </xsl:if>
            <title>
              <xsl:value-of select="//tei:notesStmt/tei:relatedItem/tei:bibl/tei:title/text()"/>
            </title>
          </titleInfo>
        </subject>
      </xsl:if>
      <xsl:if test="//tei:sourceDesc">
        <relatedItem type="host">
          <titleInfo>
            <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:title/@ref">
              <xsl:attribute name="valueURI">
                <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:title/@ref"/>
              </xsl:attribute>
            </xsl:if>
            <title>
              <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:title/text()"/>
            </title>
          </titleInfo>
          <originInfo>
            <issuance>continuing</issuance>
            <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:placeName">
              <place>
                <placeTerm>
                  <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:placeName"/>
                </placeTerm>
              </place>
            </xsl:if>
          </originInfo>
          <xsl:if
            test="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'volume'] or //tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'issue'] or //tei:sourceDesc/tei:bibl[1]/tei:date or //tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'page']">
            <part>
              <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'volume']">
                <detail type="volume">
                  <number>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'volume']"/>
                  </number>
                </detail>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'issue']">
                <detail type="issue">
                  <number>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'issue']"/>
                  </number>
                </detail>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:date">
                <date encoding="w3cdtf">
                  <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:date"/>
                </date>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'page']">
                <extent unit="pages">
                  <list>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[1]/tei:biblScope[@unit = 'page']"/>
                  </list>
                </extent>
              </xsl:if>
            </part>
          </xsl:if>
        </relatedItem>
      </xsl:if>
      <xsl:if test="//tei:sourceDesc/tei:bibl[2]">
        <relatedItem type="otherVersion">
          <titleInfo>
            <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:title/@ref">
              <xsl:attribute name="valueURI">
                <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:title/@ref"/>
              </xsl:attribute>
            </xsl:if>
            <title>
              <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:title/text()"/>
            </title>
          </titleInfo>
          <originInfo>
            <issuance>continuing</issuance>
            <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:placeName">
              <place>
                <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:placeName"/>
              </place>
            </xsl:if>
          </originInfo>
          <xsl:if
            test="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'volume'] or //tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'issue'] or //tei:sourceDesc/tei:bibl[2]/tei:date or //tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'page']">
            <part>
              <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'volume']">
                <detail type="volume">
                  <number>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'volume']"/>
                  </number>
                </detail>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'issue']">
                <detail type="issue">
                  <number>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'issue']"/>
                  </number>
                </detail>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:date">
                <date encoding="w3cdtf">
                  <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:date"/>
                </date>
              </xsl:if>
              <xsl:if test="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'page']">
                <extent unit="pages">
                  <list>
                    <xsl:value-of select="//tei:sourceDesc/tei:bibl[2]/tei:biblScope[@unit = 'page']"/>
                  </list>
                </extent>
              </xsl:if>
            </part>
          </xsl:if>
        </relatedItem>
      </xsl:if>
      <accessCondition xmlns:xlink="http://www.w3.org/1999/xlink" type="use and reproduction" xlink:href="https://creativecommons.org/licenses/by-nc/4.0/legalcode">This record is licensed under the
        Creative Commons Attribution-NonCommercial 4.0 International.</accessCondition>
      <recordInfo>
        <recordOrigin>This MODS record was generated via data transforms from a Drupal database.</recordOrigin>
        <languageOfCataloging>
          <languageTerm type="text">English</languageTerm>
        </languageOfCataloging>
        <recordContentSource>Transcultural Journalism: English Novels and the Italian Press (1720-1830)</recordContentSource>
        <recordContentSource>Canadian Writing Research Collaboratory</recordContentSource>
      </recordInfo>
    </mods>
  </xsl:template>

</xsl:stylesheet>
