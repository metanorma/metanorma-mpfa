<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:mpfd="https://www.metanorma.org/ns/mpfd" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	<xsl:param name="svg_images"/>
	<xsl:param name="external_index"/><!-- path to index xml, generated on 1st pass, based on FOP Intermediate Format -->
	<xsl:variable name="images" select="document($svg_images)"/>
	<xsl:param name="basepath"/>
	
	<xsl:key name="kfn" match="mpfd:p/mpfd:fn" use="@reference"/>
	
	
	
	<xsl:variable name="debug">false</xsl:variable>
	<xsl:variable name="pageWidth" select="'210mm'"/>
	<xsl:variable name="pageHeight" select="'297mm'"/>
	
	<xsl:variable name="copyrightHolder">Ribose Group Inc.</xsl:variable>

	<xsl:variable name="copyright">
		<xsl:text>© </xsl:text>
		<xsl:value-of select="$copyrightHolder"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:copyright/mpfd:from"/>
		<xsl:text> – All rights reserved</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="docidentifier" select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:docidentifier"/>
	<xsl:variable name="copyrightShort">
		<xsl:value-of select="$copyrightHolder"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$docidentifier"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:copyright/mpfd:from"/>
	</xsl:variable>
	
	<xsl:variable name="title-en" select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:title[@language = 'en']"/>
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents">
		<contents>			
			<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:preface/*[not(local-name() = 'terms')]" mode="contents"/>
			<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:preface/mpfd:terms" mode="contents"/>
				
			<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:sections/*" mode="contents"/>
				
			<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:annex" mode="contents"/>
			
			<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:bibliography" mode="contents"/> 			
			
		</contents>
	</xsl:variable>
	
	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>
	
	<xsl:template match="/">		
		<xsl:call-template name="namespaceCheck"/>
		<fo:root font-family="Arial" font-size="10.5pt" xml:lang="{$lang}">
			<fo:layout-master-set>
				
				<!-- cover page -->
				<fo:simple-page-master master-name="cover" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="24mm" margin-bottom="10mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="cover-header" extent="24mm"/>
					<fo:region-after region-name="footer" extent="10mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				
				<!-- document pages -->				
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="16.5mm" margin-bottom="10mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-odd" extent="16.5mm"/>
					<fo:region-after region-name="footer-odd" extent="10mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="16.5mm" margin-bottom="10mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-even" extent="16.5mm"/>
					<fo:region-after region-name="footer-even" extent="10mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				
				<fo:page-sequence-master master-name="document">
					<fo:repeatable-page-master-alternatives>						
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
			</fo:layout-master-set>

			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>
			
			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			<fo:page-sequence master-reference="cover" force-page-count="no-force">
				<fo:static-content flow-name="cover-header">
					<fo:block-container height="100%">						
							<fo:block font-size="10pt" padding-top="12.5mm">
								<xsl:value-of select="$copyright"/>								
							</fo:block>						
					</fo:block-container>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:if test="normalize-space($docidentifier) != ''">
						<fo:block font-size="14pt" text-align="right" font-weight="bold" margin-bottom="12pt">
							<xsl:value-of select="$docidentifier"/>
							<xsl:if test="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:version/mpfd:draft">
								<xsl:text> (</xsl:text>
								<xsl:text>draft </xsl:text>
								<xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:version/mpfd:draft"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:version/mpfd:revision-date"/>
								<xsl:text>)</xsl:text>
							</xsl:if>
						</fo:block>
					</xsl:if>
					<fo:block>						
						<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-MPFD-Logo))}" width="13.2mm" content-height="13mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image MPFD Logo"/>
					</fo:block>
					<fo:block-container text-align="center">
						<fo:block>								
							<fo:inline font-size="24pt" font-weight="bold">
								<xsl:call-template name="capitalizeWords">
									<xsl:with-param name="str" select="java:replaceAll(java:java.lang.String.new(/mpfd:mpfd-standard/mpfd:bibdata/mpfd:ext/mpfd:doctype),'MPF','')"/>
								</xsl:call-template>
							</fo:inline>
							<xsl:value-of select="$linebreak"/>
							<fo:inline font-size="16pt"><xsl:value-of select="$title-en"/></fo:inline>							
						</fo:block>
					</fo:block-container>
					<fo:block margin-bottom="12pt"> </fo:block>
					<fo:block-container text-align="center" border="0.5pt solid black" margin-bottom="12pt">
						<fo:block font-size="16pt" margin-bottom="12pt" padding-top="1mm">
							<xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:edition"/>
							<xsl:text> </xsl:text>
							<xsl:call-template name="getTitle">
								<xsl:with-param name="name" select="'title-edition'"/>
							</xsl:call-template>
							<xsl:value-of select="$linebreak"/>
							<xsl:call-template name="formatDate">
								<xsl:with-param name="date" select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:version/mpfd:revision-date"/>
							</xsl:call-template>							
						</fo:block>
						<fo:block>Hong Kong</fo:block>
					</fo:block-container>
					<fo:block margin-bottom="12pt"> </fo:block>
					<fo:block text-align="center">Ribose Group Inc.  <xsl:value-of select="/mpfd:mpfd-standard/mpfd:bibdata/mpfd:copyright/mpfd:from"/></fo:block>
				</fo:flow>
			</fo:page-sequence>
			
			<fo:page-sequence master-reference="document" initial-page-number="2" format="i" force-page-count="no-force">
				<xsl:call-template name="insertHeaderFooter"/>
				<fo:flow flow-name="xsl-region-body">
				
					<xsl:if test="$debug = 'true'">
						<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
							DEBUG
							contents=<xsl:copy-of select="xalan:nodeset($contents)"/>
						<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
					</xsl:if>
					<!-- Table of content -->
					<fo:block-container font-weight="bold">
						<xsl:variable name="title-toc">
							<xsl:call-template name="getTitle">
								<xsl:with-param name="name" select="'title-toc'"/>
							</xsl:call-template>
						</xsl:variable>						
						<fo:block font-size="14pt" margin-bottom="15.5pt"><xsl:value-of select="$title-toc"/></fo:block>						
						<fo:block line-height="115%">
							<xsl:for-each select="xalan:nodeset($contents)//item[@display = 'true']">
								<fo:block>
									<xsl:if test="@level = 1">
										<xsl:attribute name="margin-top">6pt</xsl:attribute>
									</xsl:if>								
									<fo:list-block provisional-label-separation="3mm">
										<xsl:attribute name="provisional-distance-between-starts">
											<xsl:choose>
												<xsl:when test="@section != ''">7mm</xsl:when>
												<xsl:otherwise>0mm</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<fo:list-item>
											<fo:list-item-label end-indent="label-end()">											
												<fo:block>
													<xsl:if test="@section">															
														<xsl:value-of select="@section"/>
													</xsl:if>
												</fo:block>
											</fo:list-item-label>
												<fo:list-item-body start-indent="body-start()">
													<fo:block text-align-last="justify">															
														<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
															<xsl:apply-templates select="title"/>
															<fo:inline keep-together.within-line="always">
																<fo:leader leader-pattern="dots"/>
																<fo:page-number-citation ref-id="{@id}"/>
															</fo:inline>
														</fo:basic-link>
													</fo:block>
												</fo:list-item-body>
										</fo:list-item>
									</fo:list-block>
								</fo:block>									
							</xsl:for-each>
						</fo:block>
					</fo:block-container>
					<xsl:if test="/mpfd:mpfd-standard/mpfd:preface/*">
						<fo:block break-after="page"/>
						<!-- Foreword, Introduction -->
						<fo:block>
							<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:preface/*[not(local-name() = 'terms')]"/>
							<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:preface/mpfd:terms"/>
						</fo:block>
					</xsl:if>
				</fo:flow>
			</fo:page-sequence>
			
			<fo:page-sequence master-reference="document" initial-page-number="1" format="1" force-page-count="no-force">
				<xsl:call-template name="insertHeaderFooter">
					<xsl:with-param name="font-weight">bold</xsl:with-param>
				</xsl:call-template>
				<fo:flow flow-name="xsl-region-body">
					<fo:block-container>
					
						
						
						<fo:block font-size="16pt" font-weight="bold" margin-bottom="18pt">
							<xsl:value-of select="$title-en"/>
						</fo:block>
						
						<!-- Main sections -->
						<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:sections/*"/>
						
						<!-- Annex(s) -->
						<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/mpfd:mpfd-standard/mpfd:bibliography"/>
					</fo:block-container>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template> 
	
	<xsl:template match="node()">
		<xsl:apply-templates/>			
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	<xsl:template match="node()" mode="contents">		
		<xsl:apply-templates mode="contents"/>			
	</xsl:template>

	<!-- element with title -->
	<xsl:template match="*[mpfd:title]" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="mpfd:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name()"/>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>				
				<xsl:when test="$level &gt;= 3">false</xsl:when>				
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::mpfd:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::mpfd:term">true</xsl:when>				
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$skip = 'false'">		
			
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<item level="{$level}" section="{$section}" type="{$type}" display="{$display}">
				<xsl:call-template name="setId"/>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
				<xsl:apply-templates mode="contents"/>
			</item>
			
		</xsl:if>	
		
	</xsl:template>

	<xsl:template match="mpfd:br" mode="contents_item" priority="2">
		<fo:inline> </fo:inline>
	</xsl:template>
	
	
	<xsl:template match="mpfd:bibitem" mode="contents"/>

	<xsl:template match="mpfd:references" mode="contents">
		<xsl:apply-templates mode="contents"/>			
	</xsl:template>
	

	<xsl:template name="getListItemFormat">
		<xsl:choose>
			<xsl:when test="local-name(..) = 'ul'">—</xsl:when> <!--•  dash -->
			<xsl:otherwise> <!-- for ordered lists -->
				<xsl:choose>
					<xsl:when test="../@type = 'arabic'">
						<xsl:number format="a)" lang="en"/>
					</xsl:when>
					<xsl:when test="../@type = 'roman'">
						<xsl:number format="1)"/>
					</xsl:when>
					<xsl:when test="../@type = 'alphabet'">
						<xsl:number format="a)" lang="en"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:number format="a)" lang="en"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================= -->
	<!-- ============================= -->
	
	
	
	<xsl:template match="mpfd:title">
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$level = 1">13pt</xsl:when>
				<xsl:when test="$level = 2">11pt</xsl:when>
				<xsl:when test="$level &gt;= 3">12pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-before">
			<xsl:choose>
					<xsl:when test="parent::mpfd:annex">0pt</xsl:when>
					<xsl:when test="$level = 1">13.5pt</xsl:when>
					<xsl:when test="$level &gt;= 2">3pt</xsl:when>
					<xsl:otherwise>6pt</xsl:otherwise>
				</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-after">
			<xsl:choose>
				<xsl:when test="$level = 1">12pt</xsl:when>
				<xsl:when test="$level &gt;= 2">12pt</xsl:when>
				<xsl:otherwise>6pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fo:block font-size="{$font-size}" color="rgb(14, 26, 133)" font-weight="bold" space-before="{$space-before}" space-after="{$space-after}" keep-with-next="always">			
			<xsl:if test="parent::mpfd:annex">
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
			
	</xsl:template>

	
	<xsl:template match="mpfd:p">
		<xsl:param name="inline" select="'false'"/>
		<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="$inline = 'true'">fo:inline</xsl:when>
				<xsl:when test="../@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title -->
				<!-- <xsl:when test="local-name(..) = 'admonition'">fo:inline</xsl:when> -->
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when>
					<xsl:when test="ancestor::mpfd:td/@align"><xsl:value-of select="ancestor::mpfd:td/@align"/></xsl:when>
					<xsl:when test="ancestor::mpfd:th/@align"><xsl:value-of select="ancestor::mpfd:th/@align"/></xsl:when>
					<xsl:otherwise>left</xsl:otherwise><!-- left. justify -->
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="text-indent">0mm</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:if test="parent::mpfd:li">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="line-height">115%</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline' and not($inline = 'true') and not(local-name(..) = 'admonition')">
			<xsl:choose>
				<xsl:when test="ancestor::mpfd:annex">
					<xsl:value-of select="$linebreak"/>
				</xsl:when>
				<xsl:otherwise>
					<fo:block margin-bottom="12pt">
						<xsl:value-of select="$linebreak"/>
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$inline = 'true'">
			<fo:block> </fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="mpfd:li//mpfd:p//text()">
		<xsl:choose>
			<xsl:when test="contains(., '&#9;')">
				<fo:inline white-space="pre"><xsl:value-of select="."/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!--
	<fn reference="1">
			<p id="_8e5cf917-f75a-4a49-b0aa-1714cb6cf954">Formerly denoted as 15 % (m/m).</p>
		</fn>
	-->
	
	<xsl:variable name="p_fn">
		<xsl:for-each select="//mpfd:p/mpfd:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]">
			<!-- copy unique fn -->
			<fn gen_id="{generate-id(.)}">
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="node()"/>
			</fn>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:template match="mpfd:p/mpfd:fn" priority="2">
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="reference" select="@reference"/>
		<xsl:variable name="number">
			<xsl:value-of select="count(xalan:nodeset($p_fn)//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="xalan:nodeset($p_fn)//fn[@gen_id = $gen_id]">
				<fo:footnote>
					<fo:inline font-size="7pt" keep-with-previous.within-line="always" vertical-align="super">
						<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
							<!-- <xsl:value-of select="@reference"/> -->
							<xsl:value-of select="$number + count(//mpfd:bibitem[ancestor::mpfd:references[@id='_normative_references' or not(preceding-sibling::mpfd:references)]]/mpfd:note)"/>
						</fo:basic-link>
					</fo:inline>
					<fo:footnote-body>
						<fo:block font-size="9pt" margin-bottom="12pt">
							<fo:inline font-size="6pt" id="footnote_{@reference}_{$number}" keep-with-next.within-line="always" vertical-align="super" padding-right="1mm">
								<xsl:value-of select="$number + count(//mpfd:bibitem[ancestor::mpfd:references[@id='_normative_references' or not(preceding-sibling::mpfd:references)]]/mpfd:note)"/>
							</fo:inline>
							<xsl:for-each select="mpfd:p">
									<xsl:apply-templates/>
							</xsl:for-each>
						</fo:block>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-size="7pt" keep-with-previous.within-line="always" vertical-align="super">
					<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
						<xsl:value-of select="$number + count(//mpfd:bibitem/mpfd:note)"/>
					</fo:basic-link>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>




	
	<xsl:template match="mpfd:bibitem">
		<fo:block id="{@id}" margin-bottom="12pt" text-indent="-11.7mm" margin-left="11.7mm"> <!-- 12 pt -->
				<!-- mpfd:docidentifier -->
			<xsl:if test="mpfd:docidentifier">
				<xsl:choose>
					<xsl:when test="mpfd:docidentifier/@type = 'metanorma'"/>
					<xsl:otherwise><fo:inline><xsl:value-of select="mpfd:docidentifier"/></fo:inline></xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates select="mpfd:note"/>
			<xsl:if test="mpfd:docidentifier">, </xsl:if>
			<fo:inline font-style="italic">
				<xsl:choose>
					<xsl:when test="mpfd:title[@type = 'main' and @language = 'en']">
						<xsl:value-of select="mpfd:title[@type = 'main' and @language = 'en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="mpfd:title"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:inline>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="mpfd:bibitem/mpfd:note">
		<fo:footnote>
			<xsl:variable name="number">
				<xsl:number level="any" count="mpfd:bibitem/mpfd:note"/>
			</xsl:variable>
			<fo:inline font-size="7pt" keep-with-previous.within-line="always" baseline-shift="30%">
				<fo:basic-link internal-destination="{generate-id()}" fox:alt-text="footnote {$number}">
					<xsl:value-of select="$number"/>
				</fo:basic-link>
			</fo:inline>
			<fo:footnote-body>
				<fo:block font-size="9pt" margin-bottom="4pt" start-indent="0pt">
					<fo:inline font-size="6pt" id="{generate-id()}" keep-with-next.within-line="always" baseline-shift="30%" padding-right="1mm"><!-- alignment-baseline="hanging" font-size="60%"  -->
						<xsl:value-of select="$number"/>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template>
	
	
	
	<xsl:template match="mpfd:ul | mpfd:ol" mode="ul_ol">
		<fo:block-container margin-left="0mm">
			<xsl:variable name="margin-left">
				<xsl:variable name="countAncestorLists" select="count(ancestor::mpfd:ul) + count(ancestor::mpfd:ol)"/>					 
				<xsl:value-of select="$countAncestorLists * 7"/>
			</xsl:variable>
			<xsl:attribute name="margin-left">
					<xsl:value-of select="concat(normalize-space($margin-left),'mm')"/>
			</xsl:attribute>
			
			<fo:block-container margin-left="0mm">
				<fo:list-block margin-bottom="12pt" provisional-distance-between-starts="6mm">
					<xsl:if test="local-name() = 'ol'">
						<xsl:attribute name="provisional-distance-between-starts">7mm</xsl:attribute>
					</xsl:if>			
					<xsl:apply-templates/>
				</fo:list-block>
				<xsl:for-each select="./mpfd:note//mpfd:p">
					<xsl:call-template name="note"/>
				</xsl:for-each>
			</fo:block-container>
		</fo:block-container>
	</xsl:template>
	
	<xsl:template match="mpfd:ul//mpfd:note |  mpfd:ol//mpfd:note" priority="2"/>
	
	<xsl:template match="mpfd:li">
		<fo:list-item id="{@id}">
			<fo:list-item-label end-indent="label-end()">
				<fo:block>
					<!-- to vertical align big dot -->	
					<!-- <xsl:if test="local-name(..) = 'ul'">
						<xsl:attribute name="font-size">18pt</xsl:attribute>
						<xsl:attribute name="margin-top">-0.5mm</xsl:attribute>
					</xsl:if> -->
					<xsl:call-template name="getListItemFormat"/>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<xsl:apply-templates/>
				<xsl:apply-templates select=".//mpfd:note" mode="process"/>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>
	
	<xsl:template match="mpfd:note" mode="process">
		<xsl:call-template name="note"/>
	</xsl:template>

	
	<xsl:template match="mpfd:preferred">		
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
		<xsl:if test="not(following-sibling::*[1][local-name() = 'preferred'])">
			<xsl:value-of select="$linebreak"/>
		</xsl:if>
	</xsl:template>

	
	<xsl:template match="mpfd:annex">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	
	<xsl:template match="mpfd:references">
		<fo:block break-after="page"/>
		<xsl:apply-templates/>
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- Example: [1] ISO 9:1995, Information and documentation – Transliteration of Cyrillic characters into Latin characters – Slavic and non-Slavic languages -->
	<xsl:template match="mpfd:references/mpfd:bibitem">
		<fo:list-block id="{@id}" margin-bottom="12pt" provisional-distance-between-starts="12mm">
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<fo:inline>
							<xsl:number format="[1]"/>
						</fo:inline>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block text-align="justify">
						<xsl:variable name="docidentifier">
							<xsl:if test="mpfd:docidentifier">
								<xsl:choose>
									<xsl:when test="mpfd:docidentifier/@type = 'metanorma'"/>
									<xsl:otherwise><xsl:value-of select="mpfd:docidentifier"/></xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:variable>
						<fo:inline><xsl:value-of select="$docidentifier"/></fo:inline>
						<xsl:apply-templates select="mpfd:note"/>
						<xsl:if test="normalize-space($docidentifier) != ''">, </xsl:if>
						<xsl:choose>
							<xsl:when test="mpfd:title[@type = 'main' and @language = 'en']">
								<xsl:apply-templates select="mpfd:title[@type = 'main' and @language = 'en']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="mpfd:title"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="mpfd:formattedref"/>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template>
	
	<xsl:template match="mpfd:references[not(@normative='true')]/mpfd:bibitem" mode="contents"/>
	
	<xsl:template match="mpfd:references[not(@normative='true')]/mpfd:bibitem/mpfd:title">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>


	<xsl:template match="mpfd:admonition">
		<fo:block text-align="center" margin-bottom="12pt" font-weight="bold">			
			<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(@type))"/>
		</fo:block>
		<fo:block font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="mpfd:formula/mpfd:stem">
		<fo:block margin-top="14pt" margin-bottom="14pt" text-align-last="justify">
			<fo:inline padding-left="5mm"><xsl:apply-templates/></fo:inline>
			<fo:inline keep-together.within-line="always">
				<fo:leader leader-pattern="space"/>
				<xsl:apply-templates select="../mpfd:name" mode="presentation"/>
			</fo:inline>
		</fo:block>		
	</xsl:template>

	<xsl:variable name="Image-MPFD-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>

	<!-- convert date from format 2007-04-01 to 1 April 2007-->
	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="number(substring($date, 9, 2))"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">January</xsl:when>
				<xsl:when test="$month = '02'">February</xsl:when>
				<xsl:when test="$month = '03'">March</xsl:when>
				<xsl:when test="$month = '04'">April</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">June</xsl:when>
				<xsl:when test="$month = '07'">July</xsl:when>
				<xsl:when test="$month = '08'">August</xsl:when>
				<xsl:when test="$month = '09'">September</xsl:when>
				<xsl:when test="$month = '10'">October</xsl:when>
				<xsl:when test="$month = '11'">November</xsl:when>
				<xsl:when test="$month = '12'">December</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="normalize-space(concat($day, ' ', $monthStr, ' ',  $year))"/>		
	</xsl:template>
	
	<xsl:template name="insertHeaderFooter">
		<xsl:param name="font-weight">normal</xsl:param>
		<fo:static-content flow-name="header-even">
			<fo:block-container height="100%" display-align="before">
				<fo:block padding-top="12.5mm">
					<xsl:value-of select="$copyrightShort"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-even">
			<fo:block-container font-size="10pt" height="100%" display-align="after">
				<fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="10%"/>
					<fo:table-column column-width="90%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell font-weight="{$font-weight}">
								<fo:block padding-bottom="5mm"><fo:page-number/></fo:block>
							</fo:table-cell>
							<fo:table-cell padding-right="2mm">
								<fo:block padding-bottom="5mm" text-align="right"><xsl:value-of select="$copyright"/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-odd">
			<fo:block-container height="100%" display-align="before">
				<fo:block text-align="right" padding-top="12.5mm">
					<xsl:value-of select="$copyrightShort"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd">
			<fo:block-container font-size="10pt" height="100%" display-align="after">
				<fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="90%"/>
					<fo:table-column column-width="10%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell>
								<fo:block padding-bottom="5mm"><xsl:value-of select="$copyright"/></fo:block>
							</fo:table-cell>
							<fo:table-cell font-weight="{$font-weight}" padding-right="2mm">
								<fo:block padding-bottom="5mm" text-align="right"><fo:page-number/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>


<xsl:variable name="titles" select="xalan:nodeset($titles_)"/><xsl:variable name="titles_">
				
		<title-annex lang="en">Annex </title-annex>
		<title-annex lang="fr">Annexe </title-annex>
		
		
				
		<title-edition lang="en">
			
				<xsl:text>Edition </xsl:text>
			
			
		</title-edition>
		
		<title-edition lang="fr">
			
				<xsl:text>Édition </xsl:text>
			
		</title-edition>
		

		<title-toc lang="en">
			
				<xsl:text>Contents</xsl:text>
			
			
			
		</title-toc>
		<title-toc lang="fr">
			
				<xsl:text>Sommaire</xsl:text>
			
			
			</title-toc>
		
		
		
		<title-page lang="en">Page</title-page>
		<title-page lang="fr">Page</title-page>
		
		<title-key lang="en">Key</title-key>
		<title-key lang="fr">Légende</title-key>
			
		<title-where lang="en">where</title-where>
		<title-where lang="fr">où</title-where>
					
		<title-descriptors lang="en">Descriptors</title-descriptors>
		
		<title-part lang="en">
			
			
			
		</title-part>
		<title-part lang="fr">
			
			
			
		</title-part>		
		<title-part lang="zh">第 # 部分:</title-part>
		
		<title-subpart lang="en">			
			
		</title-subpart>
		<title-subpart lang="fr">		
			
		</title-subpart>
		
		<title-modified lang="en">modified</title-modified>
		<title-modified lang="fr">modifiée</title-modified>
		
			<title-modified lang="zh">modified</title-modified>
		
		
		
		<title-source lang="en">
			
				<xsl:text>SOURCE</xsl:text>
						
			 
		</title-source>
		
		<title-keywords lang="en">Keywords</title-keywords>
		
		<title-deprecated lang="en">DEPRECATED</title-deprecated>
		<title-deprecated lang="fr">DEPRECATED</title-deprecated>
				
		<title-list-tables lang="en">List of Tables</title-list-tables>
		
		<title-list-figures lang="en">List of Figures</title-list-figures>
		
		<title-list-recommendations lang="en">List of Recommendations</title-list-recommendations>
		
		<title-acknowledgements lang="en">Acknowledgements</title-acknowledgements>
		
		<title-abstract lang="en">Abstract</title-abstract>
		
		<title-summary lang="en">Summary</title-summary>
		
		<title-in lang="en">in </title-in>
		
		<title-partly-supercedes lang="en">Partly Supercedes </title-partly-supercedes>
		<title-partly-supercedes lang="zh">部分代替 </title-partly-supercedes>
		
		<title-completion-date lang="en">Completion date for this manuscript</title-completion-date>
		<title-completion-date lang="zh">本稿完成日期</title-completion-date>
		
		<title-issuance-date lang="en">Issuance Date: #</title-issuance-date>
		<title-issuance-date lang="zh"># 发布</title-issuance-date>
		
		<title-implementation-date lang="en">Implementation Date: #</title-implementation-date>
		<title-implementation-date lang="zh"># 实施</title-implementation-date>

		<title-obligation-normative lang="en">normative</title-obligation-normative>
		<title-obligation-normative lang="zh">规范性附录</title-obligation-normative>
		
		<title-caution lang="en">CAUTION</title-caution>
		<title-caution lang="zh">注意</title-caution>
			
		<title-warning lang="en">WARNING</title-warning>
		<title-warning lang="zh">警告</title-warning>
		
		<title-amendment lang="en">AMENDMENT</title-amendment>
		
		<title-continued lang="en">(continued)</title-continued>
		<title-continued lang="fr">(continué)</title-continued>
		
	</xsl:variable><xsl:variable name="bibdata">
		<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']"/>
		<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'localized-strings']"/>
	</xsl:variable><xsl:variable name="tab_zh">　</xsl:variable><xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:variable name="lang_">
			<xsl:choose>
				<xsl:when test="$lang != ''">
					<xsl:value-of select="$lang"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="language" select="normalize-space($lang_)"/>
		<xsl:variable name="title_" select="$titles/*[local-name() = $name][@lang = $language]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($title_) != ''">
				<xsl:value-of select="$title_"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titles/*[local-name() = $name][@lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable name="linebreak" select="'&#8232;'"/><xsl:attribute-set name="root-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="link-style">
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		
		
		
		
		
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="permission-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-subject-style">
	</xsl:attribute-set><xsl:attribute-set name="requirement-inherit-style">
	</xsl:attribute-set><xsl:attribute-set name="recommendation-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-name-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-style">
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
			<xsl:attribute name="margin-left">12.5mm</xsl:attribute>
			<xsl:attribute name="margin-bottom">18pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
		
				
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>			
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>			
		
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-name-style">
		
		
		
				
	</xsl:attribute-set><xsl:attribute-set name="table-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
		
		
		
				
		
		
		
				
		
		
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="font-size">11pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-example-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="xref-style">
		
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="eref-style">
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-style">
		
		
		
		
				
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:variable name="note-body-indent">10mm</xsl:variable><xsl:variable name="note-body-indent-table">5mm</xsl:variable><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
				
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-name-style">		
		
				
		
	</xsl:attribute-set><xsl:attribute-set name="quote-style">		
		
		
		
		
		
		
		
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-left">12mm</xsl:attribute>
			<xsl:attribute name="margin-right">12mm</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="quote-source-style">		
		
				
				
	</xsl:attribute-set><xsl:attribute-set name="termsource-style">
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="origin-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="term-style">
		
	</xsl:attribute-set><xsl:attribute-set name="figure-name-style">
		
		
				
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>
			
	</xsl:attribute-set><xsl:attribute-set name="formula-style">
		
	</xsl:attribute-set><xsl:attribute-set name="image-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="figure-pseudocode-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="image-graphic-style">
		
		
			<xsl:attribute name="width">100%</xsl:attribute>
			<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
			<xsl:attribute name="scaling">uniform</xsl:attribute>
		
		
		
				

	</xsl:attribute-set><xsl:attribute-set name="tt-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-name-style">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="domain-style">
				
	</xsl:attribute-set><xsl:attribute-set name="admitted-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="deprecates-style">
		
	</xsl:attribute-set><xsl:attribute-set name="definition-style">
		
		
		
	</xsl:attribute-set><xsl:variable name="color-added-text">
		<xsl:text>rgb(0, 255, 0)</xsl:text>
	</xsl:variable><xsl:attribute-set name="add-style">
		<xsl:attribute name="color">red</xsl:attribute>
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
		<!-- <xsl:attribute name="color">black</xsl:attribute>
		<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
		<xsl:attribute name="padding-top">1mm</xsl:attribute>
		<xsl:attribute name="padding-bottom">0.5mm</xsl:attribute> -->
	</xsl:attribute-set><xsl:variable name="color-deleted-text">
		<xsl:text>red</xsl:text>
	</xsl:variable><xsl:attribute-set name="del-style">
		<xsl:attribute name="color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
		<xsl:attribute name="text-decoration">line-through</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="mathml-style">
		<xsl:attribute name="font-family">STIX Two Math</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:variable name="border-block-added">2.5pt solid rgb(0, 176, 80)</xsl:variable><xsl:variable name="border-block-deleted">2.5pt solid rgb(255, 0, 0)</xsl:variable><xsl:template name="processPrefaceSectionsDefault_Contents">
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='abstract']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='foreword']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='introduction']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() != 'abstract' and local-name() != 'foreword' and local-name() != 'introduction' and local-name() != 'acknowledgements']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='acknowledgements']" mode="contents"/>
	</xsl:template><xsl:template name="processMainSectionsDefault_Contents">
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='clause'][@type='scope']" mode="contents"/>			
		
		<!-- Normative references  -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']" mode="contents"/>	
		<!-- Terms and definitions -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='terms'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='terms']] |                       /*/*[local-name()='sections']/*[local-name()='definitions'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='definitions']]" mode="contents"/>		
		<!-- Another main sections -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name() != 'terms' and                                                local-name() != 'definitions' and                                                not(@type='scope') and                                               not(local-name() = 'clause' and .//*[local-name()='terms']) and                                               not(local-name() = 'clause' and .//*[local-name()='definitions'])]" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='annex']" mode="contents"/>		
		<!-- Bibliography -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][not(@normative='true')]" mode="contents"/>
	</xsl:template><xsl:template name="processPrefaceSectionsDefault">
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='abstract']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='foreword']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='introduction']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() != 'abstract' and local-name() != 'foreword' and local-name() != 'introduction' and local-name() != 'acknowledgements']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='acknowledgements']"/>
	</xsl:template><xsl:template name="processMainSectionsDefault">			
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='clause'][@type='scope']"/>
		
		<!-- Normative references  -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']"/>
		<!-- Terms and definitions -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='terms'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='terms']] |                       /*/*[local-name()='sections']/*[local-name()='definitions'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='definitions']]"/>
		<!-- Another main sections -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name() != 'terms' and                                                local-name() != 'definitions' and                                                not(@type='scope') and                                               not(local-name() = 'clause' and .//*[local-name()='terms']) and                                               not(local-name() = 'clause' and .//*[local-name()='definitions'])]"/>
		<xsl:apply-templates select="/*/*[local-name()='annex']"/>
		<!-- Bibliography -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][not(@normative='true')]"/>
	</xsl:template><xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template><xsl:template match="*[local-name()='td']//text() | *[local-name()='th']//text() | *[local-name()='dt']//text() | *[local-name()='dd']//text()" priority="1">
		<!-- <xsl:call-template name="add-zero-spaces"/> -->
		<xsl:call-template name="add-zero-spaces-java"/>
	</xsl:template><xsl:template match="*[local-name()='table']" name="table">
	
		<xsl:variable name="table-preamble">
			
			
		</xsl:variable>
		
		<xsl:variable name="table">
	
			<xsl:variable name="simple-table">	
				<xsl:call-template name="getSimpleTable"/>			
			</xsl:variable>
		
			<!-- <xsl:if test="$namespace = 'bipm'">
				<fo:block>&#xA0;</fo:block>				
			</xsl:if> -->
			
			<!-- $namespace = 'iso' or  -->
			
				<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			
					
			
				<xsl:call-template name="fn_name_display"/>
			
				
			
			<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)/*/tr[1]/td)"/>
			
			<!-- <xsl:variable name="cols-count">
				<xsl:choose>
					<xsl:when test="*[local-name()='thead']">
						<xsl:call-template name="calculate-columns-numbers">
							<xsl:with-param name="table-row" select="*[local-name()='thead']/*[local-name()='tr'][1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="calculate-columns-numbers">
							<xsl:with-param name="table-row" select="*[local-name()='tbody']/*[local-name()='tr'][1]"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable> -->
			<!-- cols-count=<xsl:copy-of select="$cols-count"/> -->
			<!-- cols-count2=<xsl:copy-of select="$cols-count2"/> -->
			
			<xsl:variable name="colwidths">
				<xsl:if test="not(*[local-name()='colgroup']/*[local-name()='col'])">
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$simple-table"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->
			
			<!-- <xsl:variable name="colwidths2">
				<xsl:call-template name="calculate-column-widths">
					<xsl:with-param name="cols-count" select="$cols-count"/>
				</xsl:call-template>
			</xsl:variable> -->
			
			<!-- cols-count=<xsl:copy-of select="$cols-count"/>
			colwidthsNew=<xsl:copy-of select="$colwidths"/>
			colwidthsOld=<xsl:copy-of select="$colwidths2"/>z -->
			
			<xsl:variable name="margin-left">
				<xsl:choose>
					<xsl:when test="sum(xalan:nodeset($colwidths)//column) &gt; 75">15</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			
			<fo:block-container margin-left="-{$margin-left}mm" margin-right="-{$margin-left}mm">			
				
				
				
							
							
							
				
				
										
				
				
				
				
				
				
					<xsl:attribute name="space-after">12pt</xsl:attribute>
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
				
				<xsl:variable name="table_width">
					<!-- for centered table always 100% (@width will be set for middle/second cell of outer table) -->
					100%
							
					
				</xsl:variable>
				
				<xsl:variable name="table_attributes">
					<attribute name="table-layout">fixed</attribute>
					<attribute name="width"><xsl:value-of select="normalize-space($table_width)"/></attribute>
					<attribute name="margin-left"><xsl:value-of select="$margin-left"/>mm</attribute>
					<attribute name="margin-right"><xsl:value-of select="$margin-left"/>mm</attribute>
					
					
					
					
					
					
									
									
									
					
					
						<attribute name="border-top">2pt solid black</attribute>
						<attribute name="border-bottom">2pt solid black</attribute>
									
					
				</xsl:variable>
				
				
				<fo:table id="{@id}" table-omit-footer-at-break="true">
					
					<xsl:for-each select="xalan:nodeset($table_attributes)/attribute">					
						<xsl:attribute name="{@name}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					
					<xsl:variable name="isNoteOrFnExist" select="./*[local-name()='note'] or .//*[local-name()='fn'][local-name(..) != 'name']"/>				
					<xsl:if test="$isNoteOrFnExist = 'true'">
						<xsl:attribute name="border-bottom">0pt solid black</xsl:attribute> <!-- set 0pt border, because there is a separete table below for footer  -->
					</xsl:if>
					
					<xsl:choose>
						<xsl:when test="*[local-name()='colgroup']/*[local-name()='col']">
							<xsl:for-each select="*[local-name()='colgroup']/*[local-name()='col']">
								<fo:table-column column-width="{@width}"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="xalan:nodeset($colwidths)//column">
								<xsl:choose>
									<xsl:when test=". = 1 or . = 0">
										<fo:table-column column-width="proportional-column-width(2)"/>
									</xsl:when>
									<xsl:otherwise>
										<fo:table-column column-width="proportional-column-width({.})"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:choose>
						<xsl:when test="not(*[local-name()='tbody']) and *[local-name()='thead']">
							<xsl:apply-templates select="*[local-name()='thead']" mode="process_tbody"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
					
				</fo:table>
				
				<xsl:variable name="colgroup" select="*[local-name()='colgroup']"/>				
				<xsl:for-each select="*[local-name()='tbody']"><!-- select context to tbody -->
					<xsl:call-template name="insertTableFooterInSeparateTable">
						<xsl:with-param name="table_attributes" select="$table_attributes"/>
						<xsl:with-param name="colwidths" select="$colwidths"/>				
						<xsl:with-param name="colgroup" select="$colgroup"/>				
					</xsl:call-template>
				</xsl:for-each>
				
				<!-- insert footer as table -->
				<!-- <fo:table>
					<xsl:for-each select="xalan::nodeset($table_attributes)/attribute">
						<xsl:attribute name="{@name}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					
					<xsl:for-each select="xalan:nodeset($colwidths)//column">
						<xsl:choose>
							<xsl:when test=". = 1 or . = 0">
								<fo:table-column column-width="proportional-column-width(2)"/>
							</xsl:when>
							<xsl:otherwise>
								<fo:table-column column-width="proportional-column-width({.})"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</fo:table>-->
				
				
				
				
				
			</fo:block-container>
		</xsl:variable>
		
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		
		<xsl:choose>
			<xsl:when test="@width">
	
				<!-- centered table when table name is centered (see table-name-style) -->
				
					<fo:table table-layout="fixed" width="100%">
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{@width}"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="2">
									<xsl:copy-of select="$table-preamble"/>
									<fo:block>
										<xsl:call-template name="setTrackChangesStyles">
											<xsl:with-param name="isAdded" select="$isAdded"/>
											<xsl:with-param name="isDeleted" select="$isDeleted"/>
										</xsl:call-template>
										<xsl:copy-of select="$table"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				
				
				
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$isAdded = 'true' or $isDeleted = 'true'">
						<xsl:copy-of select="$table-preamble"/>
						<fo:block>
							<xsl:call-template name="setTrackChangesStyles">
								<xsl:with-param name="isAdded" select="$isAdded"/>
								<xsl:with-param name="isDeleted" select="$isDeleted"/>
							</xsl:call-template>
							<xsl:copy-of select="$table"/>
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$table-preamble"/>
						<xsl:copy-of select="$table"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name() = 'name']"/><xsl:template match="*[local-name()='table']/*[local-name() = 'name']" mode="presentation">
		<xsl:param name="continued"/>
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="table-name-style">
				
				
				<xsl:choose>
					<xsl:when test="$continued = 'true'"> 
						<!-- <xsl:if test="$namespace = 'bsi'"></xsl:if> -->
						
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
				
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template><xsl:template name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>
		
		<xsl:if test="$curr-col &lt;= $cols-count">
			<xsl:variable name="widths">
				<xsl:choose>
					<xsl:when test="not($table)"><!-- this branch is not using in production, for debug only -->
						<xsl:for-each select="*[local-name()='thead']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='th'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
						</xsl:for-each>
						<xsl:for-each select="*[local-name()='tbody']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='td'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
							
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="xalan:nodeset($table)/*/tr">
							<xsl:variable name="td_text">
								<xsl:apply-templates select="td[$curr-col]" mode="td_text"/>
								
								<!-- <xsl:if test="$namespace = 'bipm'">
									<xsl:for-each select="*[local-name()='td'][$curr-col]//*[local-name()='math']">									
										<word><xsl:value-of select="normalize-space(.)"/></word>
									</xsl:for-each>
								</xsl:if> -->
								
							</xsl:variable>
							<xsl:variable name="words">
								<xsl:variable name="string_with_added_zerospaces">
									<xsl:call-template name="add-zero-spaces-java">
										<xsl:with-param name="text" select="$td_text"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="tokenize">
									<!-- <xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/> -->
									<!-- 2009 thinspace -->
									<!-- <xsl:with-param name="text" select="translate(normalize-space($td_text),'- —:', '    ')"/> -->
									<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​', ' '))"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:variable name="divider">
									<xsl:choose>
										<xsl:when test="td[$curr-col]/@divide">
											<xsl:value-of select="td[$curr-col]/@divide"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:value-of select="$max_length div $divider"/>
							</width>
							
						</xsl:for-each>
					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			
			<column>
				<xsl:for-each select="xalan:nodeset($widths)//width">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
							<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</column>
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="curr-col" select="$curr-col +1"/>
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="text()" mode="td_text">
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:value-of select="translate(., $zero-space, ' ')"/><xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='termsource']" mode="td_text">
		<xsl:value-of select="*[local-name()='origin']/@citeas"/>
	</xsl:template><xsl:template match="*[local-name()='link']" mode="td_text">
		<xsl:value-of select="@target"/>
	</xsl:template><xsl:template match="*[local-name()='math']" mode="td_text">
		<xsl:variable name="mathml">
			<xsl:for-each select="*">
				<xsl:if test="local-name() != 'unit' and local-name() != 'prefix' and local-name() != 'dimension' and local-name() != 'quantity'">
					<xsl:copy-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="math_text" select="normalize-space(xalan:nodeset($mathml))"/>
		<xsl:value-of select="translate($math_text, ' ', '#')"/><!-- mathml images as one 'word' without spaces -->
	</xsl:template><xsl:template match="*[local-name()='table2']"/><xsl:template match="*[local-name()='thead']"/><xsl:template match="*[local-name()='thead']" mode="process">
		<xsl:param name="cols-count"/>
		<!-- font-weight="bold" -->
		<fo:table-header>
			
			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template><xsl:template name="table-header-title">
		<xsl:param name="cols-count"/>
		<!-- row for title -->
		<fo:table-row>
			<fo:table-cell number-columns-spanned="{$cols-count}" border-left="1.5pt solid white" border-right="1.5pt solid white" border-top="1.5pt solid white" border-bottom="1.5pt solid black">
				
				<xsl:apply-templates select="ancestor::*[local-name()='table']/*[local-name()='name']" mode="presentation">
					<xsl:with-param name="continued">true</xsl:with-param>
				</xsl:apply-templates>
				<xsl:for-each select="ancestor::*[local-name()='table'][1]">
					<xsl:call-template name="fn_name_display"/>
				</xsl:for-each>
				
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="process_tbody">		
		<fo:table-body>
			<xsl:apply-templates/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tfoot']"/><xsl:template match="*[local-name()='tfoot']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="insertTableFooter">
		<xsl:param name="cols-count"/>
		<xsl:if test="../*[local-name()='tfoot']">
			<fo:table-footer>			
				<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
			</fo:table-footer>
		</xsl:if>
	</xsl:template><xsl:template name="insertTableFooter2">
		<xsl:param name="cols-count"/>
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		<xsl:if test="../*[local-name()='tfoot'] or           $isNoteOrFnExist = 'true'">
		
			<fo:table-footer>
			
				<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
				
				<!-- if there are note(s) or fn(s) then create footer row -->
				<xsl:if test="$isNoteOrFnExist = 'true'">
				
					
				
					<fo:table-row>
						<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
							
							
							
							<!-- fn will be processed inside 'note' processing -->
							
							
							
							
							
							
							<!-- except gb -->
							
								<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
							
							
							<!-- show Note under table in preface (ex. abstract) sections -->
							<!-- empty, because notes show at page side in main sections -->
							<!-- <xsl:if test="$namespace = 'bipm'">
								<xsl:choose>
									<xsl:when test="ancestor::*[local-name()='preface']">										
										<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
									</xsl:when>
									<xsl:otherwise>										
									<fo:block/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if> -->
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
					
				</xsl:if>
			</fo:table-footer>
		
		</xsl:if>
	</xsl:template><xsl:template name="insertTableFooterInSeparateTable">
		<xsl:param name="table_attributes"/>
		<xsl:param name="colwidths"/>
		<xsl:param name="colgroup"/>
		
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		
		<xsl:if test="$isNoteOrFnExist = 'true'">
		
			<xsl:variable name="cols-count">
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:value-of select="count(xalan:nodeset($colgroup)//*[local-name()='col'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(xalan:nodeset($colwidths)//column)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<fo:table keep-with-previous="always">
				<xsl:for-each select="xalan:nodeset($table_attributes)/attribute">
					<xsl:choose>
						<xsl:when test="@name = 'border-top'">
							<xsl:attribute name="{@name}">0pt solid black</xsl:attribute>
						</xsl:when>
						<xsl:when test="@name = 'border'">
							<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
							<xsl:attribute name="border-top">0pt solid black</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:for-each select="xalan:nodeset($colgroup)//*[local-name()='col']">
							<fo:table-column column-width="{@width}"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="xalan:nodeset($colwidths)//column">
							<xsl:choose>
								<xsl:when test=". = 1 or . = 0">
									<fo:table-column column-width="proportional-column-width(2)"/>
								</xsl:when>
								<xsl:otherwise>
									<fo:table-column column-width="proportional-column-width({.})"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
							
							
							
							<!-- fn will be processed inside 'note' processing -->
							
							
							
							
							
							
							
							<!-- except gb  -->
							
								<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
							
							
							<!-- <xsl:if test="$namespace = 'bipm'">
								<xsl:choose>
									<xsl:when test="ancestor::*[local-name()='preface']">
										show Note under table in preface (ex. abstract) sections
										<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
									</xsl:when>
									<xsl:otherwise>
										empty, because notes show at page side in main sections
									<fo:block/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if> -->
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
				
			</fo:table>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='tbody']">
		
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="../*[local-name()='thead']">					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		
		<xsl:apply-templates select="../*[local-name()='thead']" mode="process">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
		
		<xsl:call-template name="insertTableFooter">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:call-template>
		
		<fo:table-body>
			

			<xsl:apply-templates/>
			<!-- <xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/> -->
		
		</fo:table-body>
		
	</xsl:template><xsl:template match="*[local-name()='tr']">
		<xsl:variable name="parent-name" select="local-name(..)"/>
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:table-row min-height="4mm">
				<xsl:if test="$parent-name = 'thead'">
					<xsl:attribute name="font-weight">bold</xsl:attribute>
					
					
					
					
					
					
				</xsl:if>
				<xsl:if test="$parent-name = 'tfoot'">
					
					
				</xsl:if>
				
				
				
				
				<!-- <xsl:if test="$namespace = 'bipm'">
					<xsl:attribute name="height">8mm</xsl:attribute>
				</xsl:if> -->
				
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']">
		<fo:table-cell text-align="{@align}" font-weight="bold" border="solid black 1pt" padding-left="1mm" display-align="center">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:call-template name="setAlignment"/>
						<!-- <xsl:value-of select="@align"/> -->
					</xsl:when>
					<xsl:otherwise>center</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			
			
			
			
			
			
			
			
			
											
				<xsl:attribute name="border-top">solid black 2pt</xsl:attribute>
				<xsl:attribute name="border-bottom">solid black 2pt</xsl:attribute>
			
			
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="display-align"/>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="display-align">
		<xsl:if test="@valign">
			<xsl:attribute name="display-align">
				<xsl:choose>
					<xsl:when test="@valign = 'top'">before</xsl:when>
					<xsl:when test="@valign = 'middle'">center</xsl:when>
					<xsl:when test="@valign = 'bottom'">after</xsl:when>
					<xsl:otherwise>before</xsl:otherwise>
				</xsl:choose>					
			</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='td']">
		<fo:table-cell text-align="{@align}" display-align="center" border="solid black 1pt" padding-left="1mm">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:call-template name="setAlignment"/>
						<!-- <xsl:value-of select="@align"/> -->
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			
			
			
			
			
			
			
			
			
			
			
			
			<xsl:if test=".//*[local-name() = 'table']">
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="display-align"/>
			<fo:block>
								
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']" priority="2"/><xsl:template match="*[local-name()='table']/*[local-name()='note']" mode="process">
		
		
			<fo:block font-size="10pt" margin-bottom="12pt">
				
				
				
				
				
				
				<fo:inline padding-right="2mm">
					
					
					
					
					<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
						
				</fo:inline>
				
				<xsl:apply-templates mode="process"/>
			</fo:block>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='name']" mode="process"/><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='p']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="fn_display">
		<xsl:variable name="references">
			<xsl:for-each select="..//*[local-name()='fn'][local-name(..) != 'name']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					
					
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($references)//fn">
			<xsl:variable name="reference" select="@reference"/>
			<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
				<fo:block margin-bottom="12pt">
					
					
					
					
					
					<fo:inline font-size="80%" padding-right="5mm" id="{@id}">
						
						
						
						
						
						
						
						<xsl:value-of select="@reference"/>
						
						
					</fo:inline>
					<fo:inline>
						
						<!-- <xsl:apply-templates /> -->
						<xsl:copy-of select="./node()"/>
					</fo:inline>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_name_display">
		<!-- <xsl:variable name="references">
			<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates />
				</fn>
			</xsl:for-each>
		</xsl:variable>
		$references=<xsl:copy-of select="$references"/> -->
		<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
			<xsl:variable name="reference" select="@reference"/>
			<fo:block id="{@reference}_{ancestor::*[@id][1]/@id}"><xsl:value-of select="@reference"/></fo:block>
			<fo:block margin-bottom="12pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_display_figure">
		<xsl:variable name="key_iso">
			 <!-- and (not(@class) or @class !='pseudocode') -->
		</xsl:variable>
		<xsl:variable name="references">
			<xsl:for-each select=".//*[local-name()='fn'][not(parent::*[local-name()='name'])]">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		
		<!-- current hierarchy is 'figure' element -->
		<xsl:variable name="following_dl_colwidths">
			<xsl:if test="*[local-name() = 'dl']"><!-- if there is a 'dl', then set the same columns width as for 'dl' -->
				<xsl:variable name="html-table">
					<xsl:variable name="doc_ns">
						
					</xsl:variable>
					<xsl:variable name="ns">
						<xsl:choose>
							<xsl:when test="normalize-space($doc_ns)  != ''">
								<xsl:value-of select="normalize-space($doc_ns)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-before(name(/*), '-')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- <xsl:variable name="ns" select="substring-before(name(/*), '-')"/> -->
					<!-- <xsl:element name="{$ns}:table"> -->
						<xsl:for-each select="*[local-name() = 'dl'][1]">
							<tbody>
								<xsl:apply-templates mode="dl"/>
							</tbody>
						</xsl:for-each>
					<!-- </xsl:element> -->
				</xsl:variable>
				
				<xsl:call-template name="calculate-column-widths">
					<xsl:with-param name="cols-count" select="2"/>
					<xsl:with-param name="table" select="$html-table"/>
				</xsl:call-template>
				
			</xsl:if>
		</xsl:variable>
		
		
		<xsl:variable name="maxlength_dt">
			<xsl:for-each select="*[local-name() = 'dl'][1]">
				<xsl:call-template name="getMaxLength_dt"/>			
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="xalan:nodeset($references)//fn">
			<fo:block>
				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						
					</xsl:if>
					<xsl:choose>
						<!-- if there 'dl', then set same columns width -->
						<xsl:when test="xalan:nodeset($following_dl_colwidths)//column">
							<xsl:call-template name="setColumnWidth_dl">
								<xsl:with-param name="colwidths" select="$following_dl_colwidths"/>								
								<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>								
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="15%"/>
							<fo:table-column column-width="85%"/>
						</xsl:otherwise>
					</xsl:choose>
					<fo:table-body>
						<xsl:for-each select="xalan:nodeset($references)//fn">
							<xsl:variable name="reference" select="@reference"/>
							<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<fo:inline font-size="80%" padding-right="5mm" vertical-align="super" id="{@id}">
												
												<xsl:value-of select="@reference"/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block text-align="justify" margin-bottom="12pt">
											
											<xsl:if test="normalize-space($key_iso) = 'true'">
												<xsl:attribute name="margin-bottom">0</xsl:attribute>
											</xsl:if>
											
											<!-- <xsl:apply-templates /> -->
											<xsl:copy-of select="./node()"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:if>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:if>
		
	</xsl:template><xsl:template match="*[local-name()='fn']">
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:inline font-size="80%" keep-with-previous.within-line="always">
			
			
			
			
			
			
			<fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="{@reference}"> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
				
				
				<xsl:value-of select="@reference"/>
				
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='fn']/*[local-name()='p']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='dl']">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<fo:block-container>
			
				<xsl:if test="not(ancestor::*[local-name() = 'quote'])">
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
				</xsl:if>
			
			
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			<fo:block-container>
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
				<xsl:variable name="parent" select="local-name(..)"/>
				
				<xsl:variable name="key_iso">
					 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$parent = 'formula' and count(*[local-name()='dt']) = 1"> <!-- only one component -->
						
						
							<fo:block margin-bottom="12pt" text-align="left">
								
								<xsl:variable name="title-where">
									
									
										<xsl:call-template name="getTitle">
											<xsl:with-param name="name" select="'title-where'"/>
										</xsl:call-template>
									
								</xsl:variable>
								<xsl:value-of select="$title-where"/><xsl:text> </xsl:text>
								<xsl:apply-templates select="*[local-name()='dt']/*"/>
								<xsl:text/>
								<xsl:apply-templates select="*[local-name()='dd']/*" mode="inline"/>
							</fo:block>
						
					</xsl:when>
					<xsl:when test="$parent = 'formula'"> <!-- a few components -->
						<fo:block margin-bottom="12pt" text-align="left">
							
							
							
							
							<xsl:variable name="title-where">
								
								
									<xsl:call-template name="getTitle">
										<xsl:with-param name="name" select="'title-where'"/>
									</xsl:call-template>
																
							</xsl:variable>
							<xsl:value-of select="$title-where"/>
						</fo:block>
					</xsl:when>
					<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')">
						<fo:block font-weight="bold" text-align="left" margin-bottom="12pt" keep-with-next="always">
							
							
							
							<xsl:variable name="title-key">
								
								
									<xsl:call-template name="getTitle">
										<xsl:with-param name="name" select="'title-key'"/>
									</xsl:call-template>
								
							</xsl:variable>
							<xsl:value-of select="$title-key"/>
						</fo:block>
					</xsl:when>
				</xsl:choose>
				
				<!-- a few components -->
				<xsl:if test="not($parent = 'formula' and count(*[local-name()='dt']) = 1)">
					<fo:block>
						
						
						
						
						<fo:block>
							
							
							
							
							<fo:table width="95%" table-layout="fixed">
								
								<xsl:choose>
									<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'">
										<!-- <xsl:attribute name="font-size">11pt</xsl:attribute> -->
									</xsl:when>
									<xsl:when test="normalize-space($key_iso) = 'true'">
										<xsl:attribute name="font-size">10pt</xsl:attribute>
										
									</xsl:when>
								</xsl:choose>
								<!-- create virtual html table for dl/[dt and dd] -->
								<xsl:variable name="html-table">
									<xsl:variable name="doc_ns">
										
									</xsl:variable>
									<xsl:variable name="ns">
										<xsl:choose>
											<xsl:when test="normalize-space($doc_ns)  != ''">
												<xsl:value-of select="normalize-space($doc_ns)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="substring-before(name(/*), '-')"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<!-- <xsl:variable name="ns" select="substring-before(name(/*), '-')"/> -->
									<!-- <xsl:element name="{$ns}:table"> -->
										<tbody>
											<xsl:apply-templates mode="dl"/>
										</tbody>
									<!-- </xsl:element> -->
								</xsl:variable>
								<!-- html-table<xsl:copy-of select="$html-table"/> -->
								<xsl:variable name="colwidths">
									<xsl:call-template name="calculate-column-widths">
										<xsl:with-param name="cols-count" select="2"/>
										<xsl:with-param name="table" select="$html-table"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->
								<xsl:variable name="maxlength_dt">							
									<xsl:call-template name="getMaxLength_dt"/>							
								</xsl:variable>
								<xsl:call-template name="setColumnWidth_dl">
									<xsl:with-param name="colwidths" select="$colwidths"/>							
									<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>
								</xsl:call-template>
								<fo:table-body>
									<xsl:apply-templates>
										<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
									</xsl:apply-templates>
								</fo:table-body>
							</fo:table>
						</fo:block>
					</fo:block>
				</xsl:if>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template name="setColumnWidth_dl">
		<xsl:param name="colwidths"/>		
		<xsl:param name="maxlength_dt"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
				<fo:table-column column-width="50%"/>
				<fo:table-column column-width="50%"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- to set width check most wide chars like `W` -->
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 2"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="7%"/>
						<fo:table-column column-width="93%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 5"> <!-- if dt contains short text like ABC, etc -->
						<fo:table-column column-width="15%"/>
						<fo:table-column column-width="85%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 7"> <!-- if dt contains short text like ABCDEF, etc -->
						<fo:table-column column-width="20%"/>
						<fo:table-column column-width="80%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 10"> <!-- if dt contains short text like ABCDEFEF, etc -->
						<fo:table-column column-width="25%"/>
						<fo:table-column column-width="75%"/>
					</xsl:when>
					<!-- <xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.7">
						<fo:table-column column-width="60%"/>
						<fo:table-column column-width="40%"/>
					</xsl:when> -->
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.3">
						<fo:table-column column-width="50%"/>
						<fo:table-column column-width="50%"/>
					</xsl:when>
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 0.5">
						<fo:table-column column-width="40%"/>
						<fo:table-column column-width="60%"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="xalan:nodeset($colwidths)//column">
							<xsl:choose>
								<xsl:when test=". = 1 or . = 0">
									<fo:table-column column-width="proportional-column-width(2)"/>
								</xsl:when>
								<xsl:otherwise>
									<fo:table-column column-width="proportional-column-width({.})"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<!-- <fo:table-column column-width="15%"/>
				<fo:table-column column-width="85%"/> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getMaxLength_dt">
		<xsl:variable name="lengths">
			<xsl:for-each select="*[local-name()='dt']">
				<xsl:variable name="maintext_length" select="string-length(normalize-space(.))"/>
				<xsl:variable name="attributes">
					<xsl:for-each select=".//@open"><xsl:value-of select="."/></xsl:for-each>
					<xsl:for-each select=".//@close"><xsl:value-of select="."/></xsl:for-each>
				</xsl:variable>
				<length><xsl:value-of select="string-length(normalize-space(.)) + string-length($attributes)"/></length>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="maxLength">
			<!-- <xsl:for-each select="*[local-name()='dt']">
				<xsl:sort select="string-length(normalize-space(.))" data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="string-length(normalize-space(.))"/>
				</xsl:if>
			</xsl:for-each> -->
			<xsl:for-each select="xalan:nodeset($lengths)/length">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- <xsl:message>DEBUG:<xsl:value-of select="$maxLength"/></xsl:message> -->
		<xsl:value-of select="$maxLength"/>
	</xsl:template><xsl:template match="*[local-name()='dl']/*[local-name()='note']" priority="2">
		<xsl:param name="key_iso"/>
		
		<!-- <tr>
			<td>NOTE</td>
			<td>
				<xsl:apply-templates />
			</td>
		</tr>
		 -->
		<fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='dt']" mode="dl">
		<tr>
			<td>
				<xsl:apply-templates/>
			</td>
			<td>
				
				
					<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
				
			</td>
		</tr>
		
	</xsl:template><xsl:template match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		
		<fo:table-row>
			
			<fo:table-cell>
				
				<fo:block margin-top="6pt">
					
					
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
						
					</xsl:if>
					
					
					
					
					
					
					<xsl:apply-templates/>
					<!-- <xsl:if test="$namespace = 'gb'">
						<xsl:if test="ancestor::*[local-name()='formula']">
							<xsl:text>—</xsl:text>
						</xsl:if>
					</xsl:if> -->
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					
					<!-- <xsl:if test="$namespace = 'nist-cswp'  or $namespace = 'nist-sp'">
						<xsl:if test="local-name(*[1]) != 'stem'">
							<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
						</xsl:if>
					</xsl:if> -->
					
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		<!-- <xsl:if test="$namespace = 'nist-cswp'  or $namespace = 'nist-sp'">
			<xsl:if test="local-name(*[1]) = 'stem'">
				<fo:table-row>
				<fo:table-cell>
					<fo:block margin-top="6pt">
						<xsl:if test="normalize-space($key_iso) = 'true'">
							<xsl:attribute name="margin-top">0</xsl:attribute>
						</xsl:if>
						<xsl:text>&#xA0;</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			</xsl:if>
		</xsl:if> -->
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl"/><xsl:template match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']"/><xsl:template match="*[local-name()='dd']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']/*[local-name()='p']" mode="inline">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='strong'] | *[local-name()='b']">
		<fo:inline font-weight="bold">
			
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='padding']">
		<fo:inline padding-right="{@value}"> </fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='tt']">
		<fo:inline xsl:use-attribute-sets="tt-style">
			<xsl:variable name="_font-size">
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
						
			</xsl:variable>
			<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
			<xsl:if test="$font-size != ''">
				<xsl:attribute name="font-size">
					<xsl:choose>
						<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
						<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='underline']">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='add']">
		<xsl:choose>
			<xsl:when test="@amendment">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@corrigenda">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="add-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="insertTag">
		<xsl:param name="type"/>
		<xsl:param name="kind"/>
		<xsl:param name="value"/>
		<xsl:variable name="add_width" select="string-length($value) * 20"/>
		<xsl:variable name="maxwidth" select="60 + $add_width"/>
			<fo:instream-foreign-object fox:alt-text="OpeningTag" baseline-shift="-20%"><!-- alignment-baseline="middle" -->
				<!-- <xsl:attribute name="width">7mm</xsl:attribute>
				<xsl:attribute name="content-height">100%</xsl:attribute> -->
				<xsl:attribute name="height">5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="{$maxwidth + 32}" height="80">
					<g>
						<xsl:if test="$type = 'closing'">
							<xsl:attribute name="transform">scale(-1 1) translate(-<xsl:value-of select="$maxwidth + 32"/>,0)</xsl:attribute>
						</xsl:if>
						<polyline points="0,0 {$maxwidth},0 {$maxwidth + 30},40 {$maxwidth},80 0,80 " stroke="black" stroke-width="5" fill="white"/>
						<line x1="0" y1="0" x2="0" y2="80" stroke="black" stroke-width="20"/>
					</g>
					<text font-family="Arial" x="15" y="57" font-size="40pt">
						<xsl:if test="$type = 'closing'">
							<xsl:attribute name="x">25</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$kind"/><tspan dy="10" font-size="30pt"><xsl:value-of select="$value"/></tspan>
					</text>
				</svg>
			</fo:instream-foreign-object>
	</xsl:template><xsl:template match="*[local-name()='del']">
		<fo:inline xsl:use-attribute-sets="del-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='hi']">
		<fo:inline background-color="yellow">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="text()[ancestor::*[local-name()='smallcap']]">
		<xsl:variable name="text" select="normalize-space(.)"/>
		<fo:inline font-size="75%">
				<xsl:if test="string-length($text) &gt; 0">
					<xsl:call-template name="recursiveSmallCaps">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</xsl:if>
			</fo:inline> 
	</xsl:template><xsl:template name="recursiveSmallCaps">
    <xsl:param name="text"/>
    <xsl:variable name="char" select="substring($text,1,1)"/>
    <!-- <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/> -->
		<xsl:variable name="upperCase" select="java:toUpperCase(java:java.lang.String.new($char))"/>
    <xsl:choose>
      <xsl:when test="$char=$upperCase">
        <fo:inline font-size="{100 div 0.75}%">
          <xsl:value-of select="$upperCase"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$upperCase"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="string-length($text) &gt; 1">
      <xsl:call-template name="recursiveSmallCaps">
        <xsl:with-param name="text" select="substring($text,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template name="tokenize">
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:variable name="str_no_en_chars" select="normalize-space(translate($text, $en_chars, ''))"/>
					<xsl:variable name="len_str_no_en_chars" select="string-length($str_no_en_chars)"/>
					<xsl:variable name="len_str_tmp" select="string-length(normalize-space($text))"/>
					<xsl:variable name="len_str">
						<xsl:choose>
							<xsl:when test="normalize-space(translate($text, $upper, '')) = ''"> <!-- english word in CAPITAL letters -->
								<xsl:value-of select="$len_str_tmp * 1.5"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$len_str_tmp"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable> 
					
					<!-- <xsl:if test="$len_str_no_en_chars div $len_str &gt; 0.8">
						<xsl:message>
							div=<xsl:value-of select="$len_str_no_en_chars div $len_str"/>
							len_str=<xsl:value-of select="$len_str"/>
							len_str_no_en_chars=<xsl:value-of select="$len_str_no_en_chars"/>
						</xsl:message>
					</xsl:if> -->
					<!-- <len_str_no_en_chars><xsl:value-of select="$len_str_no_en_chars"/></len_str_no_en_chars>
					<len_str><xsl:value-of select="$len_str"/></len_str> -->
					<xsl:choose>
						<xsl:when test="$len_str_no_en_chars div $len_str &gt; 0.8"> <!-- means non-english string -->
							<xsl:value-of select="$len_str - $len_str_no_en_chars"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$len_str"/>
						</xsl:otherwise>
					</xsl:choose>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:value-of select="string-length(normalize-space(substring-before($text, $separator)))"/>
				</word>
				<xsl:call-template name="tokenize">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="max_length">
		<xsl:param name="words"/>
		<xsl:for-each select="$words//word">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position()=1">
						<xsl:value-of select="."/>
				</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="add-zero-spaces-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| )','$1​')"/>
	</xsl:template><xsl:template name="add-zero-spaces-link-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| |,)','$1​')"/>
	</xsl:template><xsl:template name="add-zero-spaces">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-chars">-</xsl:variable>
		<xsl:variable name="zero-space-after-dot">.</xsl:variable>
		<xsl:variable name="zero-space-after-colon">:</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space-after-underscore">_</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-chars)">
				<xsl:value-of select="substring-before($text, $zero-space-after-chars)"/>
				<xsl:value-of select="$zero-space-after-chars"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-chars)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-dot)">
				<xsl:value-of select="substring-before($text, $zero-space-after-dot)"/>
				<xsl:value-of select="$zero-space-after-dot"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-dot)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-colon)">
				<xsl:value-of select="substring-before($text, $zero-space-after-colon)"/>
				<xsl:value-of select="$zero-space-after-colon"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-colon)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-underscore)">
				<xsl:value-of select="substring-before($text, $zero-space-after-underscore)"/>
				<xsl:value-of select="$zero-space-after-underscore"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-underscore)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="add-zero-spaces-equal">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-equals">==========</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-equals)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equals)"/>
				<xsl:value-of select="$zero-space-after-equals"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equals)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getSimpleTable">
		<xsl:variable name="simple-table">
		
			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>
			
			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>
			
			<xsl:copy-of select="xalan:nodeset($simple-table-rowspan)"/>
					
			<!-- <xsl:choose>
				<xsl:when test="current()//*[local-name()='th'][@colspan] or current()//*[local-name()='td'][@colspan] ">
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="current()"/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
	</xsl:template><xsl:template match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template><xsl:template match="*[local-name()='fn']" mode="simple-table-colspan"/><xsl:template match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
		<xsl:choose>
			<xsl:when test="@colspan">
				<xsl:variable name="td">
					<xsl:element name="td">
						<xsl:attribute name="divide"><xsl:value-of select="@colspan"/></xsl:attribute>
						<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
						<xsl:apply-templates mode="simple-table-colspan"/>
					</xsl:element>
				</xsl:variable>
				<xsl:call-template name="repeatNode">
					<xsl:with-param name="count" select="@colspan"/>
					<xsl:with-param name="node" select="$td"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="td">
					<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@colspan" mode="simple-table-colspan"/><xsl:template match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template><xsl:template name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>
		
		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template><xsl:template match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]"/>
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template match="tr" mode="simple-table-rowspan">
		<xsl:param name="previousRow"/>
		<xsl:variable name="currentRow" select="."/>
	
		<xsl:variable name="normalizedTDs">
				<xsl:for-each select="xalan:nodeset($previousRow)//td">
						<xsl:choose>
								<xsl:when test="@rowspan &gt; 1">
										<xsl:copy>
												<xsl:attribute name="rowspan">
														<xsl:value-of select="@rowspan - 1"/>
												</xsl:attribute>
												<xsl:copy-of select="@*[not(name() = 'rowspan')]"/>
												<xsl:copy-of select="node()"/>
										</xsl:copy>
								</xsl:when>
								<xsl:otherwise>
										<xsl:copy-of select="$currentRow/td[1 + count(current()/preceding-sibling::td[not(@rowspan) or (@rowspan = 1)])]"/>
								</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="newRow">
				<xsl:copy>
						<xsl:copy-of select="$currentRow/@*"/>
						<xsl:copy-of select="xalan:nodeset($normalizedTDs)"/>
				</xsl:copy>
		</xsl:variable>
		<xsl:copy-of select="$newRow"/>

		<xsl:apply-templates select="following-sibling::tr[1]" mode="simple-table-rowspan">
				<xsl:with-param name="previousRow" select="$newRow"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template name="getLang">
		<xsl:variable name="language_current" select="normalize-space(//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language_current_2" select="normalize-space(xalan:nodeset($bibdata)//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$language_current != ''">
					<xsl:value-of select="$language_current"/>
				</xsl:when>
				<xsl:when test="$language_current_2 != ''">
					<xsl:value-of select="$language_current_2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//*[local-name()='bibdata']//*[local-name()='language']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalizeWords">
		<xsl:param name="str"/>
		<xsl:variable name="str2" select="translate($str, '-', ' ')"/>
		<xsl:choose>
			<xsl:when test="contains($str2, ' ')">
				<xsl:variable name="substr" select="substring-before($str2, ' ')"/>
				<!-- <xsl:value-of select="translate(substring($substr, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($substr, 2)"/> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$substr"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="substring-after($str2, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="translate(substring($str2, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($str2, 2)"/> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$str2"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalize">
		<xsl:param name="str"/>
		<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring($str, 1, 1)))"/>
		<xsl:value-of select="substring($str, 2)"/>		
	</xsl:template><xsl:template match="mathml:math">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		
		<fo:inline xsl:use-attribute-sets="mathml-style">
			
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			<xsl:variable name="mathml">
				<xsl:apply-templates select="." mode="mathml"/>
			</xsl:variable>
			<fo:instream-foreign-object fox:alt-text="Math">
				
				
				<!-- <xsl:copy-of select="."/> -->
				<xsl:copy-of select="xalan:nodeset($mathml)"/>
			</fo:instream-foreign-object>			
		</fo:inline>
	</xsl:template><xsl:template match="@*|node()" mode="mathml">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:mtext" mode="mathml">
		<xsl:copy>
			<!-- replace start and end spaces to non-break space -->
			<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'(^ )|( $)',' ')"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:mi[. = ',' and not(following-sibling::*[1][local-name() = 'mtext' and text() = ' '])]" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
		<mathml:mspace width="0.5ex"/>
	</xsl:template><xsl:template match="mathml:math/*[local-name()='unit']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='prefix']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='dimension']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='quantity']" mode="mathml"/><xsl:template match="*[local-name()='localityStack']"/><xsl:template match="*[local-name()='link']" name="link">
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="@updatetype = 'true'">
					<xsl:value-of select="concat(normalize-space(@target), '.pdf')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="target_text">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(@target), 'mailto:')">
					<xsl:value-of select="normalize-space(substring-after(@target, 'mailto:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline xsl:use-attribute-sets="link-style">
			
			<xsl:choose>
				<xsl:when test="$target_text = ''">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<fo:basic-link external-destination="{$target}" fox:alt-text="{$target}">
						<xsl:choose>
							<xsl:when test="normalize-space(.) = ''">
								<xsl:call-template name="add-zero-spaces-link-java">
									<xsl:with-param name="text" select="$target_text"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<!-- output text from <link>text</link> -->
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-style">
			<xsl:apply-templates select="*[local-name()='title']" mode="process"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='appendix']/*[local-name()='title']"/><xsl:template match="*[local-name()='appendix']/*[local-name()='title']" mode="process">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']//*[local-name()='example']" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-example-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'callout']">		
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}">&lt;<xsl:apply-templates/>&gt;</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'annotation']">
		<xsl:variable name="annotation-id" select="@id"/>
		<xsl:variable name="callout" select="//*[@target = $annotation-id]/text()"/>		
		<fo:block id="{$annotation-id}" white-space="nowrap">			
			<fo:inline>				
				<xsl:apply-templates>
					<xsl:with-param name="callout" select="concat('&lt;', $callout, '&gt; ')"/>
				</xsl:apply-templates>
			</fo:inline>
		</fo:block>		
	</xsl:template><xsl:template match="*[local-name() = 'annotation']/*[local-name() = 'p']">
		<xsl:param name="callout"/>
		<fo:inline id="{@id}">
			<!-- for first p in annotation, put <x> -->
			<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])"><xsl:value-of select="$callout"/></xsl:if>
			<xsl:apply-templates/>
		</fo:inline>		
	</xsl:template><xsl:template match="*[local-name() = 'modification']">
		<xsl:variable name="title-modified">
			
			
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'title-modified'"/>
				</xsl:call-template>
			
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$lang = 'zh'"><xsl:text>、</xsl:text><xsl:value-of select="$title-modified"/><xsl:text>—</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>, </xsl:text><xsl:value-of select="$title-modified"/><xsl:text> — </xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'xref']">
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}" xsl:use-attribute-sets="xref-style">
			
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'formula']" name="formula">
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">	
				<fo:block id="{@id}" xsl:use-attribute-sets="formula-style">
					<xsl:apply-templates/>
				</fo:block>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'dt']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'note']" name="note">
	
		<fo:block-container id="{@id}" xsl:use-attribute-sets="note-style">
			
			
			
			
			<fo:block-container margin-left="0mm">
				
				
				
				
				
				

				
					<fo:block>
						
						
						
						
						
						
						<fo:inline xsl:use-attribute-sets="note-name-style">
							
							<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
						</fo:inline>
						<xsl:apply-templates/>
					</fo:block>
				
				
			</fo:block-container>
		</fo:block-container>
		
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1">
				<fo:inline xsl:use-attribute-sets="note-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="note-p-style">						
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termnote-style">			
			<fo:inline xsl:use-attribute-sets="termnote-name-style">
				
				<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
			</fo:inline>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'name'] |               *[local-name() = 'termnote']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']" mode="presentation">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'name']" mode="presentation">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'terms']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']">
		<fo:block id="{@id}" xsl:use-attribute-sets="term-style">
			
			
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:inline>
				<xsl:apply-templates/>
				<!-- <xsl:if test="$namespace = 'gb' or $namespace = 'ogc'">
					<xsl:text>.</xsl:text>
				</xsl:if> -->
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']" name="figure">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<fo:block-container id="{@id}">			
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
			<xsl:call-template name="fn_display_figure"/>
			<xsl:for-each select="*[local-name() = 'note']">
				<xsl:call-template name="note"/>
			</xsl:for-each>
			
			
				<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
			
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
		<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']//*[local-name() = 'p']">
		<fo:block xsl:use-attribute-sets="figure-pseudocode-p-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'image']">
		<xsl:variable name="isAdded" select="../@added"/>
		<xsl:variable name="isDeleted" select="../@deleted"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'title']">
				<fo:inline padding-left="1mm" padding-right="1mm">
					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>
					<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" vertical-align="middle"/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="image-style">
					
					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="$isDeleted = 'true'">
							<!-- enclose in svg -->
							<fo:instream-foreign-object fox:alt-text="Image {@alt}">
								<xsl:attribute name="width">100%</xsl:attribute>
								<xsl:attribute name="content-height">100%</xsl:attribute>
								<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
								<xsl:attribute name="scaling">uniform</xsl:attribute>
								
								
									<xsl:apply-templates select="." mode="cross_image"/>
									
							</fo:instream-foreign-object>
						</xsl:when>
						<xsl:otherwise>
							<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" xsl:use-attribute-sets="image-graphic-style"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="image_src">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:value-of select="concat('url(file:',$basepath, @src, ')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@src"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'image']" mode="cross_image">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:variable name="src">
					<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
				</xsl:variable>
				<xsl:variable name="width" select="document($src)/@width"/>
				<xsl:variable name="height" select="document($src)/@height"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:variable name="src">
					<xsl:value-of select="concat('url(file:',$basepath, @src, ')')"/>
				</xsl:variable>
				<xsl:variable name="file" select="java:java.io.File.new(@src)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($file)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="base64String" select="substring-after(@src, 'base64,')"/>
				<xsl:variable name="decoder" select="java:java.util.Base64.getDecoder()"/>
				<xsl:variable name="fileContent" select="java:decode($decoder, $base64String)"/>
				<xsl:variable name="bis" select="java:java.io.ByteArrayInputStream.new($fileContent)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($bis)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<!-- width=<xsl:value-of select="$width"/> -->
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<!-- height=<xsl:value-of select="$height"/> -->
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{@src}" height="{$height}" width="{$width}" style="overflow:visible;"/>
					<xsl:call-template name="svg_cross">
						<xsl:with-param name="width" select="$width"/>
						<xsl:with-param name="height" select="$height"/>
					</xsl:call-template>
				</svg>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="svg_cross">
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="0" x2="{$width}" y2="{$height}" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="{$height}" x2="{$width}" y2="0" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="contents">		
		<xsl:apply-templates mode="contents"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="bookmarks">		
		<xsl:apply-templates mode="bookmarks"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement']/*[local-name() = 'name']/text()" mode="contents" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement']/*[local-name() = 'name']/text()" mode="bookmarks" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="node()" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template><xsl:template match="node()" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template match="*[local-name() = 'title' or local-name() = 'name']//*[local-name() = 'stem']" mode="contents">
		<xsl:apply-templates select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" mode="contents" priority="3"/><xsl:template match="*[local-name() = 'stem']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template name="addBookmarks">
		<xsl:param name="contents"/>
		<xsl:if test="xalan:nodeset($contents)//item">
			<fo:bookmark-tree>
				<xsl:choose>
					<xsl:when test="xalan:nodeset($contents)/doc">
						<xsl:choose>
							<xsl:when test="count(xalan:nodeset($contents)/doc) &gt; 1">
								<xsl:for-each select="xalan:nodeset($contents)/doc">
									<fo:bookmark internal-destination="{contents/item[1]/@id}" starting-state="hide">
										<fo:bookmark-title>
											<xsl:variable name="bookmark-title_">
												<xsl:call-template name="getLangVersion">
													<xsl:with-param name="lang" select="@lang"/>
													<xsl:with-param name="doctype" select="@doctype"/>
													<xsl:with-param name="title" select="@title-part"/>
												</xsl:call-template>
											</xsl:variable>
											<xsl:choose>
												<xsl:when test="normalize-space($bookmark-title_) != ''">
													<xsl:value-of select="normalize-space($bookmark-title_)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="@lang = 'en'">English</xsl:when>
														<xsl:when test="@lang = 'fr'">Français</xsl:when>
														<xsl:when test="@lang = 'de'">Deutsche</xsl:when>
														<xsl:otherwise><xsl:value-of select="@lang"/> version</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</fo:bookmark-title>
										<xsl:apply-templates select="contents/item" mode="bookmark"/>
										
										<xsl:call-template name="insertFigureBookmarks">
											<xsl:with-param name="contents" select="contents"/>
										</xsl:call-template>
										
										<xsl:call-template name="insertTableBookmarks">
											<xsl:with-param name="contents" select="contents"/>
											<xsl:with-param name="lang" select="@lang"/>
										</xsl:call-template>
										
									</fo:bookmark>
									
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="xalan:nodeset($contents)/doc">
								
									<xsl:apply-templates select="contents/item" mode="bookmark"/>
									
									<xsl:call-template name="insertFigureBookmarks">
										<xsl:with-param name="contents" select="contents"/>
									</xsl:call-template>
										
									<xsl:call-template name="insertTableBookmarks">
										<xsl:with-param name="contents" select="contents"/>
										<xsl:with-param name="lang" select="@lang"/>
									</xsl:call-template>
									
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="xalan:nodeset($contents)/contents/item" mode="bookmark"/>				
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				
				
				
				
				
			</fo:bookmark-tree>
		</xsl:if>
	</xsl:template><xsl:template name="insertFigureBookmarks">
		<xsl:param name="contents"/>
		<xsl:if test="xalan:nodeset($contents)/figure">
			<fo:bookmark internal-destination="{xalan:nodeset($contents)/figure[1]/@id}" starting-state="hide">
				<fo:bookmark-title>Figures</fo:bookmark-title>
				<xsl:for-each select="xalan:nodeset($contents)/figure">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
	</xsl:template><xsl:template name="insertTableBookmarks">
		<xsl:param name="contents"/>
		<xsl:param name="lang"/>
		<xsl:if test="xalan:nodeset($contents)/table">
			<fo:bookmark internal-destination="{xalan:nodeset($contents)/table[1]/@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'">Tableaux</xsl:when>
						<xsl:otherwise>Tables</xsl:otherwise>
					</xsl:choose>
				</fo:bookmark-title>
				<xsl:for-each select="xalan:nodeset($contents)/table">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
	</xsl:template><xsl:template name="getLangVersion">
		<xsl:param name="lang"/>
		<xsl:param name="doctype" select="''"/>
		<xsl:param name="title" select="''"/>
		<xsl:choose>
			<xsl:when test="$lang = 'en'">
				
				
				</xsl:when>
			<xsl:when test="$lang = 'fr'">
				
				
			</xsl:when>
			<xsl:when test="$lang = 'de'">Deutsche</xsl:when>
			<xsl:otherwise><xsl:value-of select="$lang"/> version</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="item" mode="bookmark">
		<fo:bookmark internal-destination="{@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:if test="@section != ''">
						<xsl:value-of select="@section"/> 
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(title)"/>
				</fo:bookmark-title>
				<xsl:apply-templates mode="bookmark"/>				
		</fo:bookmark>
	</xsl:template><xsl:template match="title" mode="bookmark"/><xsl:template match="text()" mode="bookmark"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">			
			<fo:block xsl:use-attribute-sets="figure-name-style">
				
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fn']" priority="2"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'note']"/><xsl:template match="*[local-name() = 'title']" mode="contents_item">
		<xsl:apply-templates mode="contents_item"/>
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template><xsl:template name="getSection">
		<xsl:value-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
		<!-- 
		<xsl:for-each select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()">
			<xsl:value-of select="."/>
		</xsl:for-each>
		-->
		
	</xsl:template><xsl:template name="getName">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'title']/*[local-name() = 'tab']">
				<xsl:copy-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="*[local-name() = 'title']/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertTitleAsListItem">
		<xsl:param name="provisional-distance-between-starts" select="'9.5mm'"/>
		<xsl:variable name="section">						
			<xsl:for-each select="..">
				<xsl:call-template name="getSection"/>
			</xsl:for-each>
		</xsl:variable>							
		<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}">						
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<xsl:value-of select="$section"/>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>						
						<xsl:choose>
							<xsl:when test="*[local-name() = 'tab']">
								<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template><xsl:template name="extractSection">
		<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
	</xsl:template><xsl:template name="extractTitle">
		<xsl:choose>
				<xsl:when test="*[local-name() = 'tab']">
					<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'fn']" mode="contents"/><xsl:template match="*[local-name() = 'fn']" mode="bookmarks"/><xsl:template match="*[local-name() = 'fn']" mode="contents_item"/><xsl:template match="*[local-name() = 'tab']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'strong']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'em']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'stem']" mode="contents_item">
		<xsl:copy-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'br']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']" name="sourcecode">
	
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">
	
				<fo:block xsl:use-attribute-sets="sourcecode-style">
					<xsl:variable name="_font-size">
						
												
						
						
						
						
						
						
						
								
						
						
						
												
						
								
				</xsl:variable>
				<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
				<xsl:if test="$font-size != ''">
					<xsl:attribute name="font-size">
						<xsl:choose>
							<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
							<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
					<xsl:apply-templates/>			
				</fo:block>
				<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
				
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']/text()" priority="2">
		<xsl:variable name="text">
			<xsl:call-template name="add-zero-spaces-equal"/>
		</xsl:variable>
		<xsl:call-template name="add-zero-spaces-java">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:template><xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">		
			<fo:block xsl:use-attribute-sets="sourcecode-name-style">				
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']">
		<fo:block id="{@id}" xsl:use-attribute-sets="permission-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="permission-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="permission-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']">
		<fo:block id="{@id}" xsl:use-attribute-sets="requirement-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates select="*[local-name()='label']" mode="presentation"/>
			<xsl:apply-templates select="@obligation" mode="presentation"/>
			<xsl:apply-templates select="*[local-name()='subject']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="requirement-name-style">
				
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']" mode="presentation">
		<fo:block xsl:use-attribute-sets="requirement-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/@obligation" mode="presentation">
			<fo:block>
				<fo:inline padding-right="3mm">Obligation</fo:inline><xsl:value-of select="."/>
			</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']" mode="presentation">
		<fo:block xsl:use-attribute-sets="requirement-subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'inherit']">
		<fo:block xsl:use-attribute-sets="requirement-inherit-style">
			<xsl:text>Dependency </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']">
		<fo:block id="{@id}" xsl:use-attribute-sets="recommendation-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="recommendation-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="recommendation-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
		<fo:block-container margin-left="0mm" margin-right="0mm" margin-bottom="12pt">
			<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if>
			<fo:block-container margin-left="0mm" margin-right="0mm">
				<fo:table id="{@id}" table-layout="fixed" width="100%"> <!-- border="1pt solid black" -->
					<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
						<!-- <xsl:attribute name="border">0.5pt solid black</xsl:attribute> -->
					</xsl:if>
					<xsl:variable name="simple-table">	
						<xsl:call-template name="getSimpleTable"/>			
					</xsl:variable>					
					<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
					<xsl:if test="$cols-count = 2 and not(ancestor::*[local-name()='table'])">
						<!-- <fo:table-column column-width="35mm"/>
						<fo:table-column column-width="115mm"/> -->
						<fo:table-column column-width="30%"/>
						<fo:table-column column-width="70%"/>
					</xsl:if>
					<xsl:apply-templates mode="requirement"/>
				</fo:table>
				<!-- fn processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:for-each select="*[local-name() = 'tbody']">
						<fo:block font-size="90%" border-bottom="1pt solid black">
							<xsl:call-template name="fn_display"/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="requirement">		
		<fo:table-header>			
			<xsl:apply-templates mode="requirement"/>
		</fo:table-header>
	</xsl:template><xsl:template match="*[local-name()='tbody']" mode="requirement">		
		<fo:table-body>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tr']" mode="requirement">
		<fo:table-row height="7mm" border-bottom="0.5pt solid grey">			
			<xsl:if test="parent::*[local-name()='thead']"> <!-- and not(ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']) -->
				<!-- <xsl:attribute name="border">1pt solid black</xsl:attribute> -->
				<xsl:attribute name="background-color">rgb(33, 55, 92)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Requirement ')">
				<xsl:attribute name="background-color">rgb(252, 246, 222)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Recommendation ')">
				<xsl:attribute name="background-color">rgb(233, 235, 239)</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="display-align"/>
			
			<!-- <xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(165, 165, 165)</xsl:attribute>				
			</xsl:if>
			<xsl:if test="ancestor::*[local-name()='table']/@type = 'recommendtest'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>				
			</xsl:if> -->
			
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:if test="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="padding">0mm</xsl:attribute>
				<xsl:attribute name="padding-left">0mm</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="following-sibling::*[local-name()='td'] and not(preceding-sibling::*[local-name()='td'])">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:if>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="display-align"/>
			
			<!-- <xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-left">0.5mm</xsl:attribute>
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>				 
				<xsl:if test="parent::*[local-name()='tr']/preceding-sibling::*[local-name()='tr'] and not(*[local-name()='table'])">
					<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>					
				</xsl:if>
			</xsl:if> -->
			<!-- 2nd line and below -->
			
			<fo:block>			
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@class='RecommendationTitle' or @class = 'RecommendationTestTitle']" priority="2">
		<fo:block font-size="11pt" color="rgb(237, 193, 35)"> <!-- font-weight="bold" margin-bottom="4pt" text-align="center"  -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'p2'][ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']]">
		<fo:block> <!-- margin-bottom="10pt" -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termexample-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:inline xsl:use-attribute-sets="termexample-name-style">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'example']">
		<fo:block id="{@id}" xsl:use-attribute-sets="example-style">
			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			
			<xsl:variable name="element">
				block				
				
				<xsl:if test=".//*[local-name() = 'table']">block</xsl:if> 
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="contains(normalize-space($element), 'block')">
					<fo:block xsl:use-attribute-sets="example-body-style">
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:inline>
						<xsl:apply-templates/>
					</fo:inline>
				</xsl:otherwise>
			</xsl:choose>
			
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']" mode="presentation">

		<xsl:variable name="element">
			block
			
			<xsl:if test="following-sibling::*[1][local-name() = 'table']">block</xsl:if> 
		</xsl:variable>		
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'appendix']">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="contains(normalize-space($element), 'block')">
				<fo:block xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:variable name="element">
			block
			
			
		</xsl:variable>		
		<xsl:choose>			
			<xsl:when test="normalize-space($element) = 'block'">
				<fo:block xsl:use-attribute-sets="example-p-style">
					
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-p-style">
					<xsl:apply-templates/>					
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template><xsl:template match="*[local-name() = 'termsource']" name="termsource">
		<fo:block xsl:use-attribute-sets="termsource-style">
			<!-- Example: [SOURCE: ISO 5127:2017, 3.1.6.02] -->			
			<xsl:variable name="termsource_text">
				<xsl:apply-templates/>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space($termsource_text), '[')">
					<!-- <xsl:apply-templates /> -->
					<xsl:copy-of select="$termsource_text"/>
				</xsl:when>
				<xsl:otherwise>					
					
					<!-- <xsl:apply-templates />					 -->
					<xsl:copy-of select="$termsource_text"/>
					
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template><xsl:variable name="localized.source">
		<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">source</xsl:with-param>
			</xsl:call-template>
	</xsl:variable><xsl:template match="*[local-name() = 'origin']">
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:if test="normalize-space(@citeas) = ''">
				<xsl:attribute name="fox:alt-text"><xsl:value-of select="@bibitemid"/></xsl:attribute>
			</xsl:if>
			
				<fo:inline>
					
					
					
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name" select="'title-source'"/>
						</xsl:call-template>
					
					
					<xsl:text>: </xsl:text>
				</fo:inline>
			
			<fo:inline xsl:use-attribute-sets="origin-style">
				<xsl:apply-templates/>
			</fo:inline>
			</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'quote']">		
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:if test="not(ancestor::*[local-name() = 'table'])">
					<xsl:attribute name="margin-left">5mm</xsl:attribute>
				</xsl:if>
			</xsl:if>
			
			
			<fo:block-container margin-left="0mm">
		
				<fo:block xsl:use-attribute-sets="quote-style">
					<!-- <xsl:apply-templates select=".//*[local-name() = 'p']"/> -->
					
					<xsl:apply-templates select="./node()[not(local-name() = 'author') and not(local-name() = 'source')]"/> <!-- process all nested nodes, except author and source -->
				</fo:block>
				<xsl:if test="*[local-name() = 'author'] or *[local-name() = 'source']">
					<fo:block xsl:use-attribute-sets="quote-source-style">
						<!-- — ISO, ISO 7301:2011, Clause 1 -->
						<xsl:apply-templates select="*[local-name() = 'author']"/>
						<xsl:apply-templates select="*[local-name() = 'source']"/>				
					</fo:block>
				</xsl:if>
				
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'source']">
		<xsl:if test="../*[local-name() = 'author']">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'author']">
		<xsl:text>— </xsl:text>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'eref']">
	
		<xsl:variable name="bibitemid">
			<xsl:choose>
				<xsl:when test="//*[local-name() = 'bibitem'][@hidden='true' and @id = current()/@bibitemid]"/>
				<xsl:when test="//*[local-name() = 'references'][@hidden='true']/*[local-name() = 'bibitem'][@id = current()/@bibitemid]"/>
				<xsl:otherwise><xsl:value-of select="@bibitemid"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:choose>
			<xsl:when test="normalize-space($bibitemid) != ''">
				<fo:inline xsl:use-attribute-sets="eref-style">
					<xsl:if test="@type = 'footnote'">
						
							<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
							<xsl:attribute name="font-size">80%</xsl:attribute>
							<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
							<xsl:attribute name="vertical-align">super</xsl:attribute>
											
						
					</xsl:if>	
											
					<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
						<xsl:if test="normalize-space(@citeas) = ''">
							<xsl:attribute name="fox:alt-text"><xsl:value-of select="."/></xsl:attribute>
						</xsl:if>
						<xsl:if test="@type = 'inline'">
							
								<xsl:attribute name="color">blue</xsl:attribute>
								<xsl:attribute name="text-decoration">underline</xsl:attribute>
							
							
							
						</xsl:if>

						<xsl:apply-templates/>
					</fo:basic-link>
							
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'tab']">
		<!-- zero-space char -->
		<xsl:variable name="depth">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="../@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="padding">
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			3
			
		</xsl:variable>
		
		<xsl:variable name="padding-right">
			<xsl:choose>
				<xsl:when test="normalize-space($padding) = ''">0</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($padding)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="language" select="//*[local-name()='bibdata']//*[local-name()='language']"/>
		
		<xsl:choose>
			<xsl:when test="$language = 'zh'">
				<fo:inline><xsl:value-of select="$tab_zh"/></fo:inline>
			</xsl:when>
			<xsl:when test="../../@inline-header = 'true'">
				<fo:inline font-size="90%">
					<xsl:call-template name="insertNonBreakSpaces">
						<xsl:with-param name="count" select="$padding-right"/>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="direction"><xsl:if test="$lang = 'ar'"><xsl:value-of select="$RLM"/></xsl:if></xsl:variable>
				<fo:inline padding-right="{$padding-right}mm"><xsl:value-of select="$direction"/>​</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="insertNonBreakSpaces">
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:call-template name="insertNonBreakSpaces">
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'domain']">
		<fo:inline xsl:use-attribute-sets="domain-style">&lt;<xsl:apply-templates/>&gt;</fo:inline>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']">
		<fo:block xsl:use-attribute-sets="admitted-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'deprecates']">
		<xsl:variable name="title-deprecated">
			
			
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'title-deprecated'"/>
				</xsl:call-template>
			
		</xsl:variable>
		<fo:block xsl:use-attribute-sets="deprecates-style">
			<xsl:value-of select="$title-deprecated"/>: <xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definition']">
		<fo:block xsl:use-attribute-sets="definition-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]/*[local-name() = 'p']">
		<fo:inline> <xsl:apply-templates/></fo:inline>
		<fo:block> </fo:block>
	</xsl:template><xsl:template match="/*/*[local-name() = 'sections']/*" priority="2">
		
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
			
			
			
						
			
						
			
			
			<xsl:apply-templates/>
		</fo:block>
		
		
		
	</xsl:template><xsl:template match="//*[contains(local-name(), '-standard')]/*[local-name() = 'preface']/*" priority="2"> <!-- /*/*[local-name() = 'preface']/* -->
		<fo:block break-after="page"/>
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'clause']">
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definitions']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" priority="3"/><xsl:template match="*[local-name() = 'bibitem'][@hidden='true']" priority="3"/><xsl:template match="/*/*[local-name() = 'bibliography']/*[local-name() = 'references'][@normative='true']">
		
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'annex']">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'review']">
		<!-- comment 2019-11-29 -->
		<!-- <fo:block font-weight="bold">Review:</fo:block>
		<xsl:apply-templates /> -->
	</xsl:template><xsl:template match="*[local-name() = 'name']/text()">
		<!-- 0xA0 to space replacement -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),' ',' ')"/>
	</xsl:template><xsl:template match="*[local-name() = 'ul'] | *[local-name() = 'ol']">
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'note'] or parent::*[local-name() = 'termnote']">
				<fo:block-container>
					<xsl:attribute name="margin-left">
						<xsl:choose>
							<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					
					
					
					<fo:block-container margin-left="0mm">
						<fo:block>
							<xsl:apply-templates select="." mode="ul_ol"/>
						</fo:block>
					</fo:block-container>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:apply-templates select="." mode="ul_ol"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="index" select="document($external_index)"/><xsl:variable name="dash" select="'–'"/><xsl:variable name="bookmark_in_fn">
		<xsl:for-each select="//*[local-name() = 'bookmark'][ancestor::*[local-name() = 'fn']]">
			<bookmark><xsl:value-of select="@id"/></bookmark>
		</xsl:for-each>
	</xsl:variable><xsl:template match="@*|node()" mode="index_add_id">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_add_id"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'xref']" mode="index_add_id">
		<xsl:variable name="id">
			<xsl:call-template name="generateIndexXrefId"/>
		</xsl:variable>
		<xsl:copy> <!-- add id to xref -->
			<xsl:apply-templates select="@*" mode="index_add_id"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
			<xsl:apply-templates mode="index_add_id"/>
		</xsl:copy>
		<!-- split <xref target="bm1" to="End" pagenumber="true"> to two xref:
		<xref target="bm1" pagenumber="true"> and <xref target="End" pagenumber="true"> -->
		<xsl:if test="@to">
			<xsl:value-of select="$dash"/>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:attribute name="target"><xsl:value-of select="@to"/></xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/><xsl:text>_to</xsl:text>
				</xsl:attribute>
				<xsl:apply-templates mode="index_add_id"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="index_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_update"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" mode="index_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="index_update"/>
		<xsl:apply-templates select="node()[1]" mode="process_li_element"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/node()" mode="process_li_element" priority="2">
		<xsl:param name="element"/>
		<xsl:param name="remove" select="'false'"/>
		<xsl:param name="target"/>
		<!-- <node></node> -->
		<xsl:choose>
			<xsl:when test="self::text()  and (normalize-space(.) = ',' or normalize-space(.) = $dash) and $remove = 'true'">
				<!-- skip text (i.e. remove it) and process next element -->
				<!-- [removed_<xsl:value-of select="."/>] -->
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
					<xsl:with-param name="target"><xsl:value-of select="$target"/></xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::text()">
				<xsl:value-of select="."/>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'xref'">
				<xsl:variable name="id" select="@id"/>
				<xsl:variable name="page" select="$index//item[@id = $id]"/>
				<xsl:variable name="id_next" select="following-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_next" select="$index//item[@id = $id_next]"/>
				
				<xsl:variable name="id_prev" select="preceding-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_prev" select="$index//item[@id = $id_prev]"/>
				
				<xsl:choose>
					<!-- 2nd pass -->
					<!-- if page is equal to page for next and page is not the end of range -->
					<xsl:when test="$page != '' and $page_next != '' and $page = $page_next and not(contains($page, '_to'))">  <!-- case: 12, 12-14 -->
						<!-- skip element (i.e. remove it) and remove next text ',' -->
						<!-- [removed_xref] -->
						
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
							<xsl:with-param name="target">
								<xsl:choose>
									<xsl:when test="$target != ''"><xsl:value-of select="$target"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="@target"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					
					<xsl:when test="$page != '' and $page_prev != '' and $page = $page_prev and contains($page_prev, '_to')"> <!-- case: 12-14, 14, ... -->
						<!-- remove xref -->
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>

					<xsl:otherwise>
						<xsl:apply-templates select="." mode="xref_copy">
							<xsl:with-param name="target" select="$target"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'ul'">
				<!-- ul -->
				<xsl:apply-templates select="." mode="index_update"/>
			</xsl:when>
			<xsl:otherwise>
			 <xsl:apply-templates select="." mode="xref_copy">
					<xsl:with-param name="target" select="$target"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@*|node()" mode="xref_copy">
		<xsl:param name="target"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="xref_copy"/>
			<xsl:if test="$target != '' and not(xalan:nodeset($bookmark_in_fn)//bookmark[. = $target])">
				<xsl:attribute name="target"><xsl:value-of select="$target"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="xref_copy"/>
		</xsl:copy>
	</xsl:template><xsl:template name="generateIndexXrefId">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		
		<xsl:variable name="docid">
			<xsl:call-template name="getDocumentId"/>
		</xsl:variable>
		<xsl:variable name="item_number">
			<xsl:number count="*[local-name() = 'li'][ancestor::*[local-name() = 'indexsect']]" level="any"/>
		</xsl:variable>
		<xsl:variable name="xref_number"><xsl:number count="*[local-name() = 'xref']"/></xsl:variable>
		<xsl:value-of select="concat($docid, '_', $item_number, '_', $xref_number)"/> <!-- $level, '_',  -->
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']" priority="4">
		<xsl:apply-templates/>
		<fo:block>
		<xsl:if test="following-sibling::*[local-name() = 'clause']">
			<fo:block> </fo:block>
		</xsl:if>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'ul']" priority="4">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" priority="4">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		<fo:block start-indent="{5 * $level}mm" text-indent="-5mm">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'bookmark']" name="bookmark">
		<fo:inline id="{@id}" font-size="1pt"/>
	</xsl:template><xsl:template match="*[local-name() = 'errata']">
		<!-- <row>
					<date>05-07-2013</date>
					<type>Editorial</type>
					<change>Changed CA-9 Priority Code from P1 to P2 in <xref target="tabled2"/>.</change>
					<pages>D-3</pages>
				</row>
		-->
		<fo:table table-layout="fixed" width="100%" font-size="10pt" border="1pt solid black">
			<fo:table-column column-width="20mm"/>
			<fo:table-column column-width="23mm"/>
			<fo:table-column column-width="107mm"/>
			<fo:table-column column-width="15mm"/>
			<fo:table-body>
				<fo:table-row text-align="center" font-weight="bold" background-color="black" color="white">
					
					<fo:table-cell border="1pt solid black"><fo:block>Date</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Type</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Change</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Pages</fo:block></fo:table-cell>
				</fo:table-row>
				<xsl:apply-templates/>
			</fo:table-body>
		</fo:table>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']">
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']/*">
		<fo:table-cell border="1pt solid black" padding-left="1mm" padding-top="0.5mm">
			<fo:block><xsl:apply-templates/></fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="processBibitem">
		
		
		<!-- end BIPM bibitem processing-->
		
		 
		
		
		 
		
		
		
		
	</xsl:template><xsl:template name="processBibitemDocId">
		<xsl:variable name="_doc_ident" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($_doc_ident) != ''">
				<xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]/@type"/>
				<xsl:if test="$type != '' and not(contains($_doc_ident, $type))">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$_doc_ident"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'metanorma')]/@type"/>
				<xsl:if test="$type != ''">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="*[local-name() = 'docidentifier'][not(@type = 'metanorma')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="processPersonalAuthor">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'completename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'completename']"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'initial']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'initial']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'forename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'forename']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="renderDate">		
			<xsl:if test="normalize-space(*[local-name() = 'on']) != ''">
				<xsl:value-of select="*[local-name() = 'on']"/>
			</xsl:if>
			<xsl:if test="normalize-space(*[local-name() = 'from']) != ''">
				<xsl:value-of select="concat(*[local-name() = 'from'], '–', *[local-name() = 'to'])"/>
			</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'initial']/text()" mode="strip">
		<xsl:value-of select="translate(.,'. ','')"/>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'forename']/text()" mode="strip">
		<xsl:value-of select="substring(.,1,1)"/>
	</xsl:template><xsl:template match="*[local-name() = 'title']" mode="title">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'label']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'text' or @type = 'date' or @type = 'file' or @type = 'password']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template><xsl:template name="text_input">
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="normalize-space(@maxlength) != ''"><xsl:value-of select="@maxlength"/></xsl:when>
				<xsl:when test="normalize-space(@size) != ''"><xsl:value-of select="@size"/></xsl:when>
				<xsl:otherwise>10</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="repeat">
			<xsl:with-param name="char" select="'_'"/>
			<xsl:with-param name="count" select="$count"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'button']">
		<xsl:variable name="caption">
			<xsl:choose>
				<xsl:when test="normalize-space(@value) != ''"><xsl:value-of select="@value"/></xsl:when>
				<xsl:otherwise>BUTTON</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline>[<xsl:value-of select="$caption"/>]</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'checkbox']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<polyline points="0,0 80,0 80,80 0,80 0,0" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'radio']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<circle cx="40" cy="40" r="30" stroke="black" stroke-width="5" fill="white"/>
					<circle cx="40" cy="40" r="15" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'select']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'textarea']">
		<fo:block-container border="1pt solid black" width="50%">
			<fo:block> </fo:block>
		</fo:block-container>
	</xsl:template><xsl:template name="convertDate">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">January</xsl:when>
				<xsl:when test="$month = '02'">February</xsl:when>
				<xsl:when test="$month = '03'">March</xsl:when>
				<xsl:when test="$month = '04'">April</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">June</xsl:when>
				<xsl:when test="$month = '07'">July</xsl:when>
				<xsl:when test="$month = '08'">August</xsl:when>
				<xsl:when test="$month = '09'">September</xsl:when>
				<xsl:when test="$month = '10'">October</xsl:when>
				<xsl:when test="$month = '11'">November</xsl:when>
				<xsl:when test="$month = '12'">December</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'ddMMyyyy'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr"/>
				</xsl:when>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $day, ', ' , $year))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="convertDateLocalized">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_january</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '02'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_february</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '03'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_march</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '04'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_april</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '05'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_may</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '06'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_june</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '07'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_july</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '08'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_august</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '09'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_september</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '10'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_october</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '11'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_november</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '12'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_december</xsl:with-param></xsl:call-template></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'ddMMyyyy'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr"/>
				</xsl:when>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $day, ', ' , $year))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="insertKeywords">
		<xsl:param name="sorting" select="'true'"/>
		<xsl:param name="charAtEnd" select="'.'"/>
		<xsl:param name="charDelim" select="', '"/>
		<xsl:choose>
			<xsl:when test="$sorting = 'true' or $sorting = 'yes'">
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertKeyword">
		<xsl:param name="charAtEnd"/>
		<xsl:param name="charDelim"/>
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="position() != last()"><xsl:value-of select="$charDelim"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$charAtEnd"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="addPDFUAmeta">
		<xsl:variable name="lang">
			<xsl:call-template name="getLang"/>
		</xsl:variable>
		<pdf:catalog xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf">
				<pdf:dictionary type="normal" key="ViewerPreferences">
					<pdf:boolean key="DisplayDocTitle">true</pdf:boolean>
				</pdf:dictionary>
			</pdf:catalog>
		<x:xmpmeta xmlns:x="adobe:ns:meta/">
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" rdf:about="">
				<!-- Dublin Core properties go here -->
					<dc:title>
						<xsl:variable name="title">
							<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
								
								
								
																
									<xsl:value-of select="*[local-name() = 'title'][@language = $lang]"/>
								
								
																
							</xsl:for-each>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="normalize-space($title) != ''">
								<xsl:value-of select="$title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>							
					</dc:title>
					<dc:creator>
						<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
							
							
							
						</xsl:for-each>
					</dc:creator>
					<dc:description>
						<xsl:variable name="abstract">
							
							
						</xsl:variable>
						<xsl:value-of select="normalize-space($abstract)"/>
					</dc:description>
					<pdf:Keywords>
						<xsl:call-template name="insertKeywords"/>
					</pdf:Keywords>
				</rdf:Description>
				<rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
					<!-- XMP properties go here -->
					<xmp:CreatorTool/>
				</rdf:Description>
			</rdf:RDF>
		</x:xmpmeta>
	</xsl:template><xsl:template name="getId">
		<xsl:choose>
			<xsl:when test="../@id">
				<xsl:value-of select="../@id"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="concat(local-name(..), '_', text())"/> -->
				<xsl:value-of select="concat(generate-id(..), '_', text())"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getLevel">
		<xsl:param name="depth"/>
		<xsl:choose>
			<xsl:when test="normalize-space(@depth) != ''">
				<xsl:value-of select="@depth"/>
			</xsl:when>
			<xsl:when test="normalize-space($depth) != ''">
				<xsl:value-of select="$depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level_total" select="count(ancestor::*)"/>
				<xsl:variable name="level">
					<xsl:choose>
						<xsl:when test="parent::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface'] and not(ancestor::*[local-name() = 'foreword']) and not(ancestor::*[local-name() = 'introduction'])"> <!-- for preface/clause -->
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 2"/>
						</xsl:when>
						<!-- <xsl:when test="parent::*[local-name() = 'sections']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when> -->
						<xsl:when test="ancestor::*[local-name() = 'sections']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'bibliography']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="parent::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total"/>
						</xsl:when>
						<xsl:when test="local-name() = 'annex'">1</xsl:when>
						<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$level_total - 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<xsl:param name="normalize-space" select="'true'"/>
		<xsl:if test="string-length($pText) &gt;0">
		<item>
			<xsl:choose>
				<xsl:when test="$normalize-space = 'true'">
					<xsl:value-of select="normalize-space(substring-before(concat($pText, $sep), $sep))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(concat($pText, $sep), $sep)"/>
				</xsl:otherwise>
			</xsl:choose>
		</item>
		<xsl:call-template name="split">
			<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
			<xsl:with-param name="sep" select="$sep"/>
			<xsl:with-param name="normalize-space" select="$normalize-space"/>
		</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getDocumentId">		
		<xsl:call-template name="getLang"/><xsl:value-of select="//*[local-name() = 'p'][1]/@id"/>
	</xsl:template><xsl:template name="namespaceCheck">
		<xsl:variable name="documentNS" select="namespace-uri(/*)"/>
		<xsl:variable name="XSLNS">			
			
			
			
			
			
			
			
			
			
			
			
						
			
			
				<xsl:value-of select="document('')//*/namespace::mpfd"/>
			
			
			
		</xsl:variable>
		<xsl:if test="$documentNS != $XSLNS">
			<xsl:message>[WARNING]: Document namespace: '<xsl:value-of select="$documentNS"/>' doesn't equal to xslt namespace '<xsl:value-of select="$XSLNS"/>'</xsl:message>
		</xsl:if>
	</xsl:template><xsl:template name="getLanguage">
		<xsl:param name="lang"/>		
		<xsl:variable name="language" select="java:toLowerCase(java:java.lang.String.new($lang))"/>
		<xsl:choose>
			<xsl:when test="$language = 'en'">English</xsl:when>
			<xsl:when test="$language = 'fr'">French</xsl:when>
			<xsl:when test="$language = 'de'">Deutsch</xsl:when>
			<xsl:when test="$language = 'cn'">Chinese</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="setId">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="@id">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>					
		</xsl:attribute>
	</xsl:template><xsl:template name="add-letter-spacing">
		<xsl:param name="text"/>
		<xsl:param name="letter-spacing" select="'0.15'"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<fo:inline padding-right="{$letter-spacing}mm">
				<xsl:if test="$char = '®'">
					<xsl:attribute name="font-size">58%</xsl:attribute>
					<xsl:attribute name="baseline-shift">30%</xsl:attribute>
				</xsl:if>				
				<xsl:value-of select="$char"/>
			</fo:inline>
			<xsl:call-template name="add-letter-spacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
				<xsl:with-param name="letter-spacing" select="$letter-spacing"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="repeat">
		<xsl:param name="char" select="'*'"/>
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="$char"/>
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getLocalizedString">
		<xsl:param name="key"/>	
		
		<xsl:variable name="curr_lang">
			<xsl:call-template name="getLang"/>
		</xsl:variable>
		
		<xsl:variable name="data_value" select="normalize-space(xalan:nodeset($bibdata)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang])"/>
		
		<xsl:choose>
			<xsl:when test="$data_value != ''">
				<xsl:value-of select="$data_value"/>
			</xsl:when>
			<xsl:when test="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]">
				<xsl:value-of select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$key"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="setTrackChangesStyles">
		<xsl:param name="isAdded"/>
		<xsl:param name="isDeleted"/>
		<xsl:choose>
			<xsl:when test="local-name() = 'math'">
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-added"/></xsl:attribute>
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-deleted"/></xsl:attribute>
					<xsl:if test="local-name() = 'table'">
						<xsl:attribute name="background-color">rgb(255, 185, 185)</xsl:attribute>
					</xsl:if>
					<!-- <xsl:attribute name="color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute> -->
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="LRM" select="'‎'"/><xsl:variable name="RLM" select="'‏'"/><xsl:template name="setWritingMode">
		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template name="setAlignment">
		<xsl:param name="align" select="normalize-space(@align)"/>
		<xsl:choose>
			<xsl:when test="$lang = 'ar' and $align = 'left'">start</xsl:when>
			<xsl:when test="$lang = 'ar' and $align = 'right'">end</xsl:when>
			<xsl:when test="$align != ''">
				<xsl:value-of select="$align"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template></xsl:stylesheet>