header {
package org.antcl.parser;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;
}

class RTFRecognizer extends Parser;
options {
    k                       = 3;
    exportVocab             = RTF;
    defaultErrorHandler     = true;
}

rtffile     : bgroup rtfheader document egroup EOF ;
rtfheader   : version charset (deff)? fonttbl (filetbl)? (colortbl)? (stylesheet)? (listtables)? (revtbl)? ;
document    : ( info | docvar | hdrftr | pndef | para )* ;

para        : textpar | table ;

textpar     : apoctl | tabdef | rtf_char /*( "par" para )?*/ ;

rtf_char    :   ptext
            |   atext
            |   field
            |   book
            |   shp
            |   shppict
            |   annot
            |   foot
            |   obj
/*          |   pict
            |   dobj
            |   idx
            |   toc*/
            |   listtext
            |   datafield
            |   unicode_represent
            |   bgroup (rtf_char)* egroup
            ;

ptext       : docfmt | secfmt | parfmt | chrfmt | revmarkfmt | data | semi ;
atext       : ( "loch" | "hich" | "dbch" ) ( aprops | chrfmt_plain | chrfmt_style | pcdata ) ;

plain_char  :   plain_ptext
            |   plain_atext
            |   bgroup (plain_char)* egroup
            ;

plain_ptext : /*secfmt_style |*/ parfmt | chrfmt | data ;

plain_atext : ( "loch" | "hich" | "dbch" ) ( aprops | chrfmt_plain | chrfmt_style ) ;

data        :   pcdata
            |   spec
            |   unicode_char
            ;

/**
 *   Sub-structure Defination
 */

version     : "rtf" ;
charset     : ( "ansi" | "mac" | "pc" | "pca" ) ( unicode_charset )? ;
unicode_charset
            : "ansicpg" "uc" ;
deff        : "deff" ( languagedef )* ;

fonttbl     : bgroup "fonttbl" ( fontinfo /*| ( bgroup fontinfo egroup )*/)+ egroup ;
fontinfo    : fontnum fontfamily (fcharset)? (fprq)? (panose)? (nontaggedname)? (fontemb)? (codepage)? fontname (fontaltname)? semi ;
fontnum     : "f" ;
fontfamily  : "fnil" | "froman" | "fswiss" | "fmodern" | "fscript" | "fdecor" | "ftech" | "fbidi" ;
fcharset    : "fcharset" ;
fprq        : "fprq" ;
panose      : bgroup "panose" (pcdata)* egroup ;
nontaggedname
            : bgroup /*IGNORABLE_DESTINATION*/ "fname" egroup ;

fontemb     : bgroup /*IGNORABLE_DESTINATION*/ "fontemb" fonttype (fontfname)? (pcdata)* egroup ;
fonttype    : "ftnil" | "fttruetype" ;
fontfname   : bgroup /*IGNORABLE_DESTINATION*/ "fontfile" (codepage)? (pcdata)* egroup ;
codepage    : "cpg" ;
fontname    : (pcdata | hex_value)* ;
fontaltname : bgroup /*IGNORABLE_DESTINATION*/ "falt" (pcdata | hex_value)* egroup ;

filetbl     : bgroup /*IGNORABLE_DESTINATION*/ "filetbl" ( bgroup fileinfo egroup )+ egroup ;
fileinfo    : "file" filenum (relpath)? (osnum)? (filesource)+ filename ;
filenum     : "fid" ;
relpath     : "frelative" ;
osnum       : "fosnum" ;
filesource  : "fvalidmac" | "fvaliddos" | "fvalidntfs" | "fvalidhpfs" | "fnetwork" ;
filename    : (pcdata)* ;

colortbl    : bgroup "colortbl" ( ( colordef )* semi )+ egroup ;
colordef    : "red" | "green" | "blue" ;

stylesheet  : bgroup "stylesheet" (style)+ egroup ;
style       : /*bgroup*/ (styledef)? (keycode)? (additive)? (formatting)? (based)? (next)? (autoupd)? (hidden)? (personal)? (compose)? (reply)? stylename semi /*egroup*/ ;
styledef    : parfmt_style | /*IGNORABLE_DESTINATION*/ chrfmt_style | secfmt_style ;
keycode     : bgroup /*IGNORABLE_DESTINATION*/ "keycode" keys egroup ;
keys        : ( "shift" | "ctrl" | "alt" )* key ;
key         : "fn" | (pcdata)* ;
formatting  : ( docfmt | parfmt_plain | par_shading | par_brdrdef | "ls" | chrfmt_plain | plain_atext/* | apoctl*/ | tabdef )+ ;
additive    : "additive" ;
based       : "sbasedon" ;
next        : "snext" ;
autoupd     : "sautoupd" ;
hidden      : "shidden" ;
personal    : "spersonal" ;
compose     : "scompose" ;
reply       : "sreply" ;
stylename   : (pcdata)* ;

listtables  : listtable ( listoverridetable )? ;

listtable   : bgroup "listtable" (list)+ egroup ;
list        : bgroup "list" ( "listtemplateid" | "listsimple" | "listhybrid" | "listrestarthdn" | "listid" | listlevel | listname )* egroup ;
listlevel   : bgroup "listlevel" ( listlevel_number | listlevel_justification | listlevel_ )* leveltext levelnumbers (tabdef | rtf_char)* /*( "li" | "fi" | "jclisttab" "tx" )**/ egroup ;

listlevel_number
            :   "levelnfc"
            |   "levelnfcn"
            ;

listlevel_justification
            :   "leveljc"
            |   "leveljcn"
            ;

listlevel_  :   "levelstartat"
            |   "levelold"
            |   "levelprev"
            |   "levelprevspace"
            |   "levelspace"
            |   "levelindent"
            |   "levelfollow"
            |   "levellegal"
            |   "levelnorestart"
            ;

leveltext   : bgroup "leveltext" ("leveltemplateid")? (plain_char)* semi egroup ;
levelnumbers: bgroup "levelnumbers" (plain_char)* semi egroup ;
listname    : bgroup "listname" (pcdata)* semi egroup ;

listoverridetable
            : bgroup "listoverridetable" (listoverride)+ egroup ;

listoverride: bgroup "listoverride" ( "listid" | "listoverridecount" | "ls" | lfolevel )* egroup ;

lfolevel    : bgroup "lfolevel" ( "listoverridestartat" | "levelstartat" | "listoverrideformat" )* egroup ;

revtbl      : bgroup /*IGNORABLE_DESTINATION*/ "revtbl" /*bgroup*/ (pcdata)* semi /*egroup*/ egroup ;

info        :   bgroup "info"
                (
                    bgroup
                    (   title
                    |   subject
                    |   author
                    |   manager
                    |   company
                    |   operator
                    |   category
                    |   keywords
                    |   comment
                    |   doccomm
                    |   creatim
                    |   revtim
                    |   printim
                    |   buptim
                    |   "version"
                    |   "vern"
                    |   "edmins"
                    |   "nofpages"
                    |   "nofwords"
                    |   "nofchars"
                    |   "nofcharsws"
                    |   "id"
                    )
                    egroup
                )*
                egroup
                (userprops)?
            ;

title       : "title"       (pcdata)* ;
subject     : "subject"     (pcdata)* ;
author      : "author"      (pcdata)* ;
manager     : "manager"     (pcdata)* ;
company     : "company"     (pcdata)* ;
operator    : "operator"    (pcdata)* ;
keywords    : "keywords"    (pcdata)* ;
category    : "category"    (pcdata)* ;
comment     : "comment"     (pcdata)* ;
doccomm     : "doccomm"     (pcdata)* ;
hlinkbase   : "hlinkbase"   (pcdata)* ;
creatim     : "creatim"     time   ;
revtim      : "revtim"      time   ;
printim     : "printim"     time   ;
buptim      : "buptim"      time   ;
time        : ("yr")? ("mo")? ("dy")? ("hr")? ("min")? ("sec")? ;

userprops   : bgroup "userprops" (propinfo)* egroup ;
propinfo    : propname proptype staticval (linkval)? ;
propname    : bgroup "propname" (pcdata)* egroup ;
proptype    : "proptype" ;
staticval   : bgroup "staticval" (pcdata)* egroup ;
linkval     : bgroup "linkval" (pcdata)* egroup ;

docvar      : bgroup "docvar" /*varname vartext*/ (plain_char)* egroup ;
varname     : bgroup (plain_char)* egroup ;
vartext     : bgroup (plain_char)* egroup ;

//section   : (secfmt)* (hdrftr)* (para)* ;

hdrftr      : bgroup hdrctl (para)* egroup ;

pndef       : pnseclvl | pnpara ;
pnseclvl    : bgroup "pnseclvl" (pndesc)* egroup ;

pnpara      : pntext pnprops ;
pntext      : bgroup "pntext" (rtf_char)* egroup ;
pnprops     : bgroup "pn" pnlevel (pndesc)* egroup ;

pnlevel     :   "pnlvl"
            |   "pnlvlblt"
            |   "pnlvlbody"
            |   "pnlvlcont"
            ;

pndesc      :   pnnstyle
            |   pnchrfmt
            |   pntxtb
            |   pntxta
            |   pnfmt
            ;

pnnstyle    :   "pncard"
            |   "pndec"
            |   "pnucltr"
            |   "pnucrm"
            |   "pnlcltr"
            |   "pnlcrm"
            |   "pnord"
            |   "pnordt"
            |   "pnbidia"
            |   "pnbidib"
            |   "pnaiu"
            |   "pnaiud"
            |   "pnaiueo"
            |   "pnaiueod"
            |   "pnchosung"
            |   "pncnum"
            |   "pndbnum"
            |   "pndbnumd"
            |   "pndbnumk"
            |   "pndbnuml"
            |   "pndbnumt"
            |   "pndecd"
            |   "pnganada"
            |   "pngbnum"
            |   "pngbnumd"
            |   "pngbnumk"
            |   "pngbnuml"
            |   "pniroha"
            |   "pnirohad"
            |   "pnuldash"
            |   "pnuldashd"
            |   "pnuldashdd"
            |   "pnulhair"
            |   "pnulth"
            |   "pnulwave"
            |   "pnzodiac"
            |   "pnzodiacd"
            |   "pnzodiacl"
            ;

pnchrfmt    :   "pnf"
            |   "pnfs"
            |   "pnb"
            |   "pni"
            |   "pncaps"
            |   "pnscaps"
            |   "pnstrike"
            |   "pncf"
            |   pnul
            ;

pnul        :   "pnul"
            |   "pnuld"
            |   "pnuldb"
            |   "pnulnone"
            |   "pnulw"
            ;

pnfmt       :   "pnnumonce"
            |   "pnacross"
            |   "pnindent"
            |   "pnsp"
            |   "pnprev"
            |   "pnstart"
            |   "pnhang"
            |   "pnrestart"
            |   pnjust
            ;

pnjust      :   "pnqc"
            |   "pnql"
            |   "pnqr"
            ;

pntxtb      :   bgroup "pntxtb" (rtf_char)* egroup ;
pntxta      :   bgroup "pntxta" (rtf_char)* egroup ;


shppict     :   bgroup ("shppict" | "nonshppict") pict egroup ;

pict        :   bgroup "pict" ( /*brdr | shading |*/ picttype | pictsize | picprop | metafileinfo | pictdata )* egroup ;

picttype    :   "emfblip"
            |   "pngblip"
            |   "jpegblip"
            |   "macpict"
            |   "pmmetafile"
            |   "wmetafile"
            |   "dibitmap" bitmapinfo
            |   "wbitmap" bitmapinfo
            ;

bitmapinfo  :   "wbmbitspixel"
            |   "wbmplanes"
            |   "wbmwidthbytes"
            ;

pictsize    :   "picw"
            |   "pich"
            |   "picwgoal"
            |   "pichgoal"
            |   "picscalex"
            |   "picscaley"
            |   "picscaled"
            |   "piccropt"
            |   "piccropb"
            |   "piccropr"
            |   "piccropl"
            |   "defshp"
            ;

picprop     :   bgroup "picprop" (shpfmt | shptxt | sp)* egroup ;

metafileinfo:   "picbmp"
            |   "picbpp"
            ;

pictdata    :   "bliptag"
            |   "blipupi"
            |   bgroup ( "blipuid" | "bin" ) (pcdata)* egroup
            |   pcdata
            ;

shp         :   bgroup "shp"
                    bgroup "shpinst" ( shpfmt | shptxt | sp )* egroup
                    bgroup "shprslt" dobj egroup
                egroup
            ;

shptxt      :   bgroup "shptxt" (rtf_char)* egroup
            ;

sp          :   bgroup "sp"
                    bgroup "sn" (pcdata)* egroup
                    bgroup "sv" ( pcdata | semi | pict | hyperlink )* egroup
                egroup
            ;

shpfmt      :   "shpleft"
            |   "shptop"
            |   "shpbottom"
            |   "shpright"
            |   "shplid"
            |   "shpz"
            |   "shpfhdr"
            |   "shpbxpage"
            |   "shpbxmargin"
            |   "shpbxcolumn"
            |   "shpbxignore"
            |   "shpbypage"
            |   "shpbymargin"
            |   "shpbypara"
            |   "shpbyignore"
            |   "shpwr"
            |   "shpwrk"
            |   "shpfblwtxt"
            |   "shplockanchor"
            ;

//\shptxt
//\shprslt
//\shpgrp

dobj        :   bgroup "do" dohead dpinfo egroup ;
dohead      :   dobx doby dodhgt (dolock)? ;
dobx        :   "dobxpage" | "dobxcolumn" | "dobxmargin" ;
doby        :   "dobypage" | "dobypara" | "dobymargin" ;
dodhgt      :   "dodhgt" ;
dolock      :   "dolock" ;

dpinfo      :   dpgroup | dpcallout | dpsimple ;

dpgroup     :   "dpgroup" "dpcount" dphead (dpinfo)+ "dpendgroup" dphead ;

dpcallout   :   "dpcallout" cotype (coangle)? (coaccent)? (cosmartattach)? (cobestfit)? (cominusx)? (cominusy)? (coborder)? (codescent)? "dpcooffset" "dpcolength" dphead dppolyline dphead dpprops dptextbox dphead dpprops ;

dpsimple    :   dpsimpledpk dphead dpprops ;

dpsimpledpk :   dpline | dprect | dptextbox | dpellipse | dppolyline | dparc ;
dpline      :   "dpline" dppt dppt ;
dprect      :   "dprect" ("dproundr")? ;
dptextbox   :   ( "dptxbx" | "dptxlrtb" | "dptxtbrl" | "dptxbtlr" | "dptxlrtbv" | "dptxtbrlv" | "dptxbxmar" | bgroup "dptxbxtext" (para)+ egroup )+ ;
dpellipse   :   "dpellipse" ;
dppolyline  :   "dppolyline" ("dppolygon")? "dppolycount" (dppt)+ ;
dparc       :   "dparc" ("dparcflipx")? ("dparcflipy")? ;

dppt        :   "dpptx" "dppty" ;

dphead      :   "dpx" "dpy" "dpxsize" "dpysize" ;

dpprops     :   ( lineprops | fillprops | endstylestart | endstyleend | shadow )* ;

cotype      :   "dpcotright" | "dpcotsingle" | "dpcotdouble" | "dpcottriple" ;
coangle     :   "dpcoa" ;
coaccent    :   "dpcoaccent" ;
cosmartattach
            :   "dpcosmarta" ;
cobestfit   :   "dpcobestfit" ;
cominusx    :   "dpcominusx" ;
cominusy    :   "dpcominusy" ;
coborder    :   "dpcoborder" ;
codescent   :   "dpcodtop" | "dpcodcenter" | "dpcodbottom" | "dpcodabs" ;

lineprops   :   linestyle | linecolor | "dplinew" ;
linestyle   :   "dplinesolid" | "dplinehollow" | "dplinedash" | "dplinedot" | "dplinedado" | "dplinedadodo" ;
linecolor   :   linegray | linergb ;
linegray    :   "dplinegray" ;
linergb     :   "dplinecor" "dplinecog" "dplinecob" (linepal)? ;
linepal     :   "dplinepal" ;
fillprops   :   fillcolorfg fillcolorbg "dpfillpat" ;
fillcolorfg :   fillfggray | fillfgrgb ;
fillfggray  :   "dpfillfggray" ;
fillfgrgb   :   "dpfillfgcr" "dpfillfgcg" "dpfillfgcb" (fillfgpal)? ;
fillfgpal   :   "dpfillfgpal" ;
fillcolorbg :   fillbggray | fillbgrgb ;
fillbggray  :   "dpfillbggray" ;
fillbgrgb   :   "dpfillbgcr" "dpfillbgcg" "dpfillbgcb" (fillbgpal)? ;
fillbgpal   :   "dpfillbgpal" ;
endstylestart
            :   arrowstartfill "dpastartl" "dpastartw" ;
arrowstartfill
            :   "dpastartsol" | "dpastarthol" ;
endstyleend :   arrowendfill "dpaendl" "dpaendw" ;
arrowendfill:   "dpaendsol" | "dpaendhol" ;
shadow      :   "dpshadow" "dpshadx" "dpshady" ;

hyperlink   :   bgroup "hl"
                    bgroup "hlloc" (pcdata)* egroup
                    bgroup "hlsrc" (pcdata)* egroup
                    bgroup "hlfr" (pcdata)* egroup
                egroup
            ;

listtext    : bgroup "listtext" (plain_char)* egroup ;

datafield   : bgroup "datafield" (pcdata)* egroup ;

foot        : bgroup "footnote" ("ftnalt")? (rtf_char)* egroup ;

obj         :   bgroup "object" (   objtype
                                |   objmod
                                |   objclass
                                |   objname
                                |   objtime
                                |   objsize
                                |   rsltmod
                                )*
                                objdata
                                result
                egroup
//          |   pubobject
            ;

objtype     : "objemb" | "objlink" | "objautlink" | "objsub" | "objpub" | "objicemb" | "objhtml" | "objocx" ;
objmod      : "linkself" | "objlock" | "objupdate" ;
objclass    : bgroup "objclass" (pcdata)* egroup ;
objname     : bgroup "objname" (pcdata)* egroup ;
objtime     : bgroup "objtime" time egroup ;
rsltmod     : "rsltmerge" | rslttype ;
rslttype    : "rsltrtf" | "rslttxt" | "rsltpict" | "rsltbmp" | "rslthtml" ;
objsize     : "objsetsize" | "objalign" | "objtransy" | objhw | "objcropt" | "objcropb" | "objcropl" | "objcropr" | "objscalex" | "objscaley" ;
objhw       : "objh" | "objw" ;
objdata     : bgroup "objdata" ( objalias | objsect )* (pcdata)* egroup ;
objalias    : bgroup "objalias" (pcdata)* egroup ;
objsect     : bgroup "objsect" (pcdata)* egroup ;
result      : bgroup "result" (para)+ egroup ;

annot       : annotid atnauthor (atntime)? "chatn" (atnicn)? annotdef ;
annotid     : bgroup "atnid" (pcdata)* egroup ;
atnauthor   : bgroup "atnauthor" (pcdata)* egroup ;
atntime     : bgroup "atntime" time egroup ;
atnicn      : bgroup "atnicn" pict egroup ;
annotdef    : bgroup "annotation" (atnref)? ( plain_char | field )* egroup ;
atnref      : bgroup "atnref" (pcdata)* egroup ;

book        : bookstart | bookend | atrfstart | atrfend | pubobject ;
bookstart   : bgroup "bkmkstart" /*( "bkmkcolf" | "bkmkcoll" )**/ (pcdata)* egroup ;
bookend     : bgroup "bkmkend" (pcdata)* egroup ;

atrfstart   : bgroup "atrfstart" (pcdata)* egroup ;
atrfend     : bgroup "atrfend" (pcdata)* egroup ;

pubobject   : bgroup "bkmkstart" "bkmkpub" ("pubauto")? ( objalias | objsect )* (pcdata)* egroup ;

field       : bgroup "field" (fieldmod)* fieldinst fieldrslt egroup ;
fieldmod    : "flddirty" | "fldedit" | "fldlock" | "fldpriv" ;
fieldinst   : bgroup "fldinst" (rtf_char)* (fldalt)? egroup ;
fldalt      : "fldalt" ;
fieldrslt   : bgroup "fldrslt" (rtf_char)* egroup ;


idx         : bgroup "xe" ( "xef" | "bxe" | "ixe" )* entry ( txe | rxe )* egroup ;
entry       : bgroup (plain_char)* (yxe)? egroup ;
yxe         : "yxe" (plain_char)* ;
txe         : bgroup "txe" (plain_char)* egroup ;
rxe         : bgroup "rxe" (plain_char)* egroup ;

toc         : bgroup ( "tc" | "tcn" ("tcf" | "tcl")* ) (plain_char)* egroup ;

par_brdrdef : par_brdrseg brdr ;

par_brdrseg :   "brdrt"
            |   "brdrb"
            |   "brdrl"
            |   "brdrr"
            |   "brdrbtw"
            |   "brdrbar"
            |   "box"
            ;

chr_brdrdef : chr_brdrseg brdr ;

chr_brdrseg : "chbrdr" ;

brdr        : brdrk ("brdrw")? ("brsp")? ("brdrcf")? ;

brdrk       :   "brdrs"
            |   "brdrth"
            |   "brdrsh"
            |   "brdrdb"
            |   "brdrdot"
            |   "brdrdash"
            |   "brdrhair"
            |   "brdrinset"
            |   "brdrdashsm"
            |   "brdrdashd"
            |   "brdrdashdd"
            |   "brdrtriple"
            |   "brdrtnthsg"
            |   "brdrthtnsg"
            |   "brdrtnthtnsg"
            |   "brdrtnthmg"
            |   "brdrthtnmg"
            |   "brdrtnthtnmg"
            |   "brdrtnthlg"
            |   "brdrthtnlg"
            |   "brdrtnthtnlg"
            |   "brdrwavy"
            |   "brdrwavydb"
            |   "brdrdashdotstr"
            |   "brdremboss"
            |   "brdrengrave"
            |   "brdroutset"
            |   "brdrnone"
            ;


apoctl      : framesize | horzpos | vertpos | txtwrap | dropcap | txtflow | "absnoovrlp" ;
horzpos     : hframe | hdist ;
vertpos     : vframe | vdist ;

framesize   :   "absw"
            |   "absh"
            ;

txtwrap     :   "nowrap"
            |   "dxfrtext"
            |   "dfrmtxtx"
            |   "dfrmtxty"
            ;

dropcap     :   "dropcapli"
            |   "dropcapt"
            ;

hframe      :   "phmrg"
            |   "phpg"
            |   "phcol"
            ;

hdist       :   "posx"
            |   "posnegx"
            |   "posxc"
            |   "posxi"
            |   "posxo"
            |   "posxl"
            |   "posxr"
            ;

vframe      :   "pvmrg"
            |   "pvpg"
            |   "pvpara"
            ;

vdist       :   "posy"
            |   "posnegy"
            |   "posyt"
            |   "posyil"
            |   "posyb"
            |   "posyc"
            |   "posyin"
            |   "posyout"
            |   "abslock"
            ;

txtflow     :   "frmtxlrtb"
            |   "frmtxtbrl"
            |   "frmtxbtlr"
            |   "frmtxlrtbv"
            |   "frmtxtbrlv"
            ;

tabdef      : tab /*| bartab*/ ;
tab         : ( tabkind | tablead | "jclisttab" )* "tx" ;
//bartab    : (tablead)? "tb" ;

tabkind     :   "tqr"
            |   "tqc"
            |   "tqdec"
            ;

tablead     :   "tldot"
            |   "tlmdot"
            |   "tlhyph"
            |   "tlul"
            |   "tlth"
            |   "tleq"
            ;

par_shading : ( "shading" | par_pat ) /*("cfpat")? ("cbpat")?*/ ;

par_pat     :   "bghoriz"
            |   "bgvert"
            |   "bgfdiag"
            |   "bgbdiag"
            |   "bgcross"
            |   "bgdcross"
            |   "bgdkhoriz"
            |   "bgdkvert"
            |   "bgdkfdiag"
            |   "bgdkbdiag"
            |   "bgdkcross"
            |   "bgdkdcross"
            ;

chr_shading : ( "chshdng" | chr_pat ) ("chcfpat")? ("chcbpat")? ("fbias")? ;

chr_pat     :   "chbghoriz"
            |   "chbgvert"
            |   "chbgfdiag"
            |   "chbgbdiag"
            |   "chbgcross"
            |   "chbgdcross"
            |   "chbgdkhoriz"
            |   "chbgdkvert"
            |   "chbgdkfdiag"
            |   "chbgdkbdiag"
            |   "chbgdkcross"
            |   "chbgdkdcross"
            ;

chr_revmark :   "revised"
            |   "revauth"
            |   "revdttm"
            |   "crauth"
            |   "crdate"
            |   "revauthdel"
            |   "revdttmdel"
            ;

tbldef      :   "trowd" "trgaph"
                (   rowjust
                |   rowwrite
                |   rowtop
                |   rowbot
                |   rowleft
                |   rowright
                |   rowhor
                |   rowvert
                |   rowpos
                |   "trleft"
                |   "trrh"
                |   "trhdr"
                |   "trkeep"
                |   rowwidth
                |   rowinv
                |   "trautofit"
                |   rowspc
                |   rowpad
                |   "taprtl"
                )*
                (celldef)+
            ;

rowjust     : "trql" | "trqr" | "trqc" ;
rowwrite    : "ltrrow" | "rtlrow" ;
rowtop      : "trbrdrt" brdr ;
rowbot      : "trbrdrl" brdr ;
rowleft     : "trbrdrb" brdr ;
rowright    : "trbrdrr" brdr ;
rowhor      : "trbrdrh" brdr ;
rowvert     : "trbrdrv" brdr ;

rowpos      : rowhorzpos | rowvertpos | rowwrap | "tabsnoovrlp" ;
rowhorzpos  : rowhframe | rowhdist ;
rowvertpos  : rowvframe | rowvdist ;

rowwrap     :   "tdfrmtxtLeft"
            |   "tdfrmtxtRight"
            |   "tdfrmtxtTop"
            |   "tdfrmtxtBottom"
            ;

rowhframe   :   "phmrg"
            |   "phpg"
            |   "phcol"
            ;

rowhdist    :   "tposx"
            |   "tposnegx"
            |   "tposxc"
            |   "tposxi"
            |   "tposxo"
            |   "tposxl"
            |   "tposxr"
            ;

rowvframe   :   "tpvmrg"
            |   "tpvpg"
            |   "tpvpara"
            ;

rowvdist    :   "tposy"
            |   "tposnegy"
            |   "tposyt"
            |   "tposyil"
            |   "tposyb"
            |   "tposyc"
            |   "tposyin"
            |   "tposyout"
            ;

rowwidth    :   "trftsWidth"
            |   "trwWidth"
            ;

rowinv      :   "trftsWidthB"
            |   "trftsWidthA"
            |   "trwWidthB"
            |   "trwWidthA"
            ;

rowspc      :   "trspdl"
            |   "trspdfl"
            |   "trspdt"
            |   "trspdft"
            |   "trspdb"
            |   "trspdfb"
            |   "trspdr"
            |   "trspdfr"
            ;

rowpad      :   "trpaddl"
            |   "trpaddfl"
            |   "trpaddt"
            |   "trpaddft"
            |   "trpaddb"
            |   "trpaddfb"
            |   "trpaddr"
            |   "trpaddfr"
            ;


celldef     :   (   "clmgf"
                |   "clmrg"
                |   "clvmgf"
                |   "clvmrg"
                |   celldgu
                |   celldgl
                |   cellalign
                |   celltop
                |   cellleft
                |   cellbot
                |   cellright
                |   cellshad
                |   cellflow
                |   "clFitText"
                |   "clNoWrap"
                |   cellwidth
                |   cellpad
                )*
                "cellx"
            ;

celldgu     : "cldglu" brdr ;
celldgl     : "cldgll" brdr ;
cellalign   : "clvertalt" | "clvertalc" | "clvertalb" ;
celltop     : "clbrdrt" brdr ;
cellleft    : "clbrdrl" brdr ;
cellbot     : "clbrdrb" brdr ;
cellright   : "clbrdrr" brdr ;

cellshad    : cellpat | "clcfpat" | "clcbpat" | "clshdng" ;

cellpat     :   "clbghoriz"
            |   "clbgvert"
            |   "clbgfdiag"
            |   "clbgbdiag"
            |   "clbgcross"
            |   "clbgdcross"
            |   "clbgdkhor"
            |   "clbgdkvert"
            |   "clbgdkfdiag"
            |   "clbgdkbdiag"
            |   "clbgdkcross"
            |   "clbgdkdcross"
            ;

cellflow    :   "cltxlrtb"
            |   "cltxtbrl"
            |   "cltxbtlr"
            |   "cltxlrtbv"
            |   "cltxtbrlv"
            ;

cellwidth   :   "clftsWidth"
            |   "clwWidth"
            ;

cellpad     :   "clpadl"
            |   "clpadfl"
            |   "clpadt"
            |   "clpadft"
            |   "clpadb"
            |   "clpadfb"
            |   "clpadr"
            |   "clpadfr"
            ;

table       :   ( tbldef cell tbldef "row" )
//          |   ( tbldef (cell)+ "row" )
//          |   ( (cell)+ tbldef "row" )
            ;

cell        : /*((nestrow)? (tbldef)?) &*/ (rtf_char)* ( "cell" (rtf_char)* )* ;
//nestrow   : (nestcell)+ bgroup "nesttableprops" tbldef "nestrow" egroup ;
//nestcell  : (textpar)+ "nestcell" ;

aprops      :   "ab"
            |   "acaps"
            |   "acf"
            |   "adn"
            |   "aexpnd"
            |   "af"
            |   "afs"
            |   "ai"
            |   "alang"
            |   "aoutl"
            |   "ascaps"
            |   "ashad"
            |   "astrike"
            |   "aul"
            |   "auld"
            |   "auldb"
            |   "aulnone"
            |   "aulw"
            |   "aup"
            ;

hdrctl      :   "header"
            |   "footer"
            |   "headerl"
            |   "headerr"
            |   "headerf"
            |   "footerl"
            |   "footerr"
            |   "footerf"
            ;

languagedef :   "deflang"
            |   "deflangfe" ;

docfmt      :   docfmts
            |   viewsZoomLevel
            |   footnotesEndnotes
            |   pageInformation
            |   linkedStyles
            |   compatibilityOptions
            |   forms
            |   revisionMarks
            |   annotations
            |   bidirectionalControls
            |   clickType
            |   kinsokuCharacters
            |   drawingGrid
            |   pageBorders
            ;

docfmts     :   "deftab"
            |   "hyphhotz"
            |   "hyphconsec"
            |   "hyphcaps"
            |   "hyphauto"
            |   "linestart"
            |   "fracwidth"
            |   "nextfile"
            |   "template"
            |   "makebackup"
            |   "defformat"
            |   "psover"
            |   "doctemp"
            |   "deflang"
            |   "deflangfe"
            |   "windowcaption"
            |   "doctype"
            |   "fromtext"
            |   "fromhtml"
            |   "horzdoc"
            |   "vertdoc"
            |   "jcompress"
            |   "jexpand"
            |   "lnongrid"
            ;

viewsZoomLevel
            :   "viewkind"
            |   "viewscale"
            |   "viewzk"
            |   "private"
            ;

footnotesEndnotes
            :   "fet"
            |   "ftncn"
            |   "aftncn"
            |   "endnotes"
            |   "enddoc"
            |   "ftntj"
            |   "ftnbj"
            |   "aendnotes"
            |   "aenddoc"
            |   "aftnbj"
            |   "aftntj"
            |   "ftnstart"
            |   "aftnstart"
            |   "ftnrstpg"
            |   "ftnrestart"
            |   "ftnrstcont"
            |   "aftnrestart"
            |   "aftnrstcont"
            |   "ftnnar"
            |   "ftnnalc"
            |   "ftnnauc"
            |   "ftnnrlc"
            |   "ftnnruc"
            |   "ftnnchi"
            |   "ftnnchosung"
            |   "ftnncnum"
            |   "ftnndbnum"
            |   "ftnndbnumd"
            |   "ftnndbnumt"
            |   "ftnndbnumk"
            |   "ftnndbar"
            |   "ftnnganada"
            |   "ftnngbnum"
            |   "ftnngbnumd"
            |   "ftnngbnuml"
            |   "ftnngbnumk"
            |   "ftnnzodiac"
            |   "ftnnzodiacd"
            |   "ftnnzodiacl"
            |   "aftnnar"
            |   "aftnnalc"
            |   "aftnnauc"
            |   "aftnnrlc"
            |   "aftnnruc"
            |   "aftnnchi"
            |   "aftnnchosung"
            |   "aftnncnum"
            |   "aftnndbnum"
            |   "aftnndbnumd"
            |   "aftnndbnumt"
            |   "aftnndbnumk"
            |   "aftnndbar"
            |   "aftnnganada"
            |   "aftnngbnum"
            |   "aftnngbnumd"
            |   "aftnngbnuml"
            |   "aftnngbnumk"
            |   "aftnnzodiac"
            |   "aftnnzodiacd"
            |   "aftnnzodiacl"
            ;

pageInformation
            :   "paperw"
            |   "paperh"
            |   "margl"
            |   "margr"
            |   "margt"
            |   "margb"
            |   "facingp"
            |   "gutter"
            |   "rtlgutter"
            |   "gutterprl"
            |   "margmirror"
            |   "landscape"
            |   "pgnstart"
            |   "widowctrl"
            |   "twoonone"
            ;

linkedStyles
            :   "linkstyles"
            ;

compatibilityOptions
            :   "notabind"
            |   "wraptrsp"
            |   "prcolbl"
            |   "noextrasprl"
            |   "nocolbal"
            |   "cvmme"
            |   "sprstsp"
            |   "sprsspbf"
            |   "otblrul"
            |   "transmf"
            |   "swpbdr"
            |   "brkfrm"
            |   "sprslnsp"
            |   "subfontbysize"
            |   "truncatefont"
            |   "truncex"
            |   "bdbfhdr"
            |   "dntblnsbdb"
            |   "expshrtn"
            |   "lytexcttp"
            |   "lytprtmet"
            |   "msmcap"
            |   "nolead"
            |   "nospaceforul"
            |   "noultrlspc"
            |   "noxlattoyen"
            |   "oldlinewrap"
            |   "sprsbsp"
            |   "sprstsm"
            |   "wpjst"
            |   "wpsp"
            |   "wptab"
            |   "splytwnine"
            |   "ftnlytwnine"
            |   "htmautsp"
            |   "useltbaln"
            |   "alntblind"
            |   "lytcalctblwd"
            |   "lyttblrtgr"
            |   "oldas"
            |   "lnbrkrule"
            |   "bdrrlswsix"
            |   "nolnhtadjtbl"
            ;

forms       :   "formprot"
            |   "allprot"
            |   "formshade"
            |   "formdisp"
            |   "printdata"
            ;

revisionMarks
            :   "revprot"
            |   "revisions"
            |   "revprop"
            |   "revbar"
            ;

annotations :   "annotprot"
            ;

bidirectionalControls
            :   "rtldoc"
            |   "ltrdoc"
            ;

clickType   :   "cts"
            ;

kinsokuCharacters
            :   "jsksu"
            |   "ksulang"
            |   "fchars"
            |   "lchars"
            ;

drawingGrid :   "dghspace"
            |   "dgvspace"
            |   "dghorigin"
            |   "dgvorigin"
            |   "dghshow"
            |   "dgvshow"
            |   "dgsnap"
            |   "dgmargin"
            ;

pageBorders :   "pgbrdrhead"
            |   "pgbrdrfoot"
            |   "pgbrdrt"
            |   "pgbrdrb"
            |   "pgbrdrl"
            |   "pgbrdrr"
            |   "brdrart"
            |   "pgbrdropt"
            |   "pgbrdrsnap"
            ;

secfmt      :   secfmt_plain
            |   secfmt_style
            |   secfmt_pageInformation
            |   secfmt_footnotesEndnotes
            ;

secfmt_plain:   "sect"
            |   "sectd"
            |   "endnhere"
            |   "binfsxn"
            |   "binsxn"
            |   "sectunlocked"
            |   sectionBreak
            |   columns
            |   lineNumbering
            |   secPageInformation
            |   pageNumbers
            |   verticalAlignment
            |   secBidirectionalControls
            |   asianControls
            |   textFlow
            |   lineCharacterGrid
            ;

secfmt_pageInformation
            :   "psz"
            ;

secfmt_footnotesEndnotes
            :   "ftnsep"
            |   "ftnsepc"
            |   "aftnsep"
            |   "aftnsepc"
            ;

sectionBreak:   "sbknone"
            |   "sbkcol"
            |   "sbkpage"
            |   "sbkeven"
            |   "sbkodd"
            ;

columns     :   "cols"
            |   "colsx"
            |   "colno"
            |   "colsr"
            |   "colw"
            |   "linebetcol"
            ;

lineNumbering
            :   "linemod"
            |   "linex"
            |   "linestarts"
            |   "linerestart"
            |   "lineppage"
            |   "linecont"
            ;

secPageInformation
            :   "pgwsxn"
            |   "pghsxn"
            |   "marglsxn"
            |   "margrsxn"
            |   "margtsxn"
            |   "margbsxn"
            |   "guttersxn"
            |   "margmirsxn"
            |   "lndscpsxn"
            |   "titlepg"
            |   "headery"
            |   "footery"
            ;

pageNumbers :   "pgnstarts"
            |   "pgncont"
            |   "pgnrestart"
            |   "pgnx"
            |   "pgny"
            |   "pgndec"
            |   "pgnucrm"
            |   "pgnlcrm"
            |   "pgnucltr"
            |   "pgnlcltr"
            |   "pgnbidia"
            |   "pgnbidib"
            |   "pgnchosung"
            |   "pgncnum"
            |   "pgndbnum"
            |   "pgndbnumd"
            |   "pgndbnumt"
            |   "pgndbnumk"
            |   "pgndecd"
            |   "pgnganada"
            |   "pgngbnum"
            |   "pgngbnumd"
            |   "pgngbnuml"
            |   "pgngbnumk"
            |   "pgnzodiac"
            |   "pgnzodiacd"
            |   "pgnzodiacl"
            |   "pgnhn"
            |   "pgnhnsh"
            |   "pgnhnsp"
            |   "pgnhnsc"
            |   "pgnhnsm"
            |   "pgnhnsn"
            ;

verticalAlignment
            :   "vertalt"
            |   "vertalb"
            |   "vertalc"
            |   "vertalj"
            ;

secBidirectionalControls
            :   "rtlsect"
            |   "ltrsect"
            ;

asianControls
            :   "horzsect"
            |   "vertsect"
            ;

textFlow    :   "stextflow"
            ;

lineCharacterGrid
            :   "sectexpand"
            |   "sectlinegrid"
            |   "sectdefaultcl"
            |   "sectspecifycl"
            |   "sectspecifyl"
            |   "sectspecifygen"
            ;

revmarkfmt  :   "pnrauth"
            |   "pnrdate"
            |   "pnrnot"
            |   "pnrxst"
            |   "pnrrgb"
            |   "pnrnfc"
            |   "pnrpnbr"
            |   "pnrstart"
            |   "pnrstop"
            |   "dfrauth"
            |   "dfrdate"
            |   "dfrxst"
            |   "dfrstart"
            |   "dfrstop"
            ;

parfmt      :   parfmt_plain
            |   parfmt_style
            |   par_shading
            |   par_brdrdef
            |   "ls"
            |   "pn"
            ;

parfmt_plain:   "par"
            |   "pard"
            |   "plain"
            |   "hyphpar"
            |   "intbl"
            |   "itap"
            |   "keep"
            |   "keepn"
            |   "level"
            |   "noline"
            |   "nowidctlpar"
            |   "widctlpar"
            |   "outlinelevel"
            |   "pagebb"
            |   "sbys"
            |   "qc"
            |   "qj"
            |   "ql"
            |   "qr"
            |   "qd"
            |   "faauto"
            |   "fahang"
            |   "facenter"
            |   "faroman"
            |   "favar"
            |   "fafixed"
            |   "fi"
            |   "cufi"
            |   "li"
            |   "lin"
            |   "culi"
            |   "ri"
            |   "rin"
            |   "curi"
            |   "adjustright"
            |   "sb"
            |   "sa"
            |   "sbauto"
            |   "saauto"
            |   "lisb"
            |   "lisa"
            |   "sl"
            |   "slmult"
            |   "nosnaplinegrid"
            |   "subdocument"
            |   "rtlpar"
            |   "ltrpar"
            |   "nocwrap"
            |   "nowwrap"
            |   "nooverflow"
            |   "aspalpha"
            |   "aspnum"
            |   "collapsed"
            |   "cfpat"
            |   "cbpat"
            ;

chrfmt      :   chrfmt_plain
            |   chrfmt_style
            |   chr_shading
            |   chr_brdrdef
            |   chr_unicode
            |   "highlight"
//          |   atext
            ;

chr_unicode :   "uc"
            ;

chrfmt_plain:   "animtext"
            |   "accnone"
            |   "accdot"
            |   "acccomma"
            |   "b"
            |   "caps"
            |   "cb"
            |   "cchs"
            |   "cf"
            |   "charscalex"
            |   "cgrid"
            |   "g"
            |   "gcw"
            |   "gridtbl"
            |   "deleted"
            |   "dn"
            |   "embo"
            |   "expnd"
            |   "expndtw"
            |   "fittext"
            |   "f"
            |   "fs"
            |   "i"
            |   "impr"
            |   "kerning"
            |   "langfe"
            |   "langfenp"
            |   "lang"
            |   "langnp"
            |   "ltrch"
            |   "rtlch"
            |   "noproof"
            |   "nosupersub"
            |   "nosectexpand"
            |   "outl"
            |   "scaps"
            |   "shad"
            |   "strike"
            |   "striked"
            |   "sub"
            |   "super"
            |   "ul"
            |   "ulc"
            |   "uld"
            |   "uldash"
            |   "uldashd"
            |   "uldashdd"
            |   "uldb"
            |   "ulhwave"
            |   "ulldash"
            |   "ulnone"
            |   "ulth"
            |   "ulthd"
            |   "ulthdash"
            |   "ulthdashd"
            |   "ulthdashdd"
            |   "ulthldash"
            |   "ululdbwave"
            |   "ulw"
            |   "ulwave"
            |   "up"
            |   "v"
            |   "webhidden"
            ;

parfmt_style:   "s"     ;
secfmt_style:   "ds"    ;
chrfmt_style:   "cs"    ;

//A carriage return (character value 13) or linefeed (character value 10) will be treated as a \par
//A tab (character value 9) should be treated as a \tab control word
spec        :   "chdate"
            |   "chdpl"
            |   "chdpa"
            |   "chtime"
            |   "chpgn"
            |   "sectnum"
            |   "chftn"
            |   "chatn"
            |   "chftnsep"
            |   "chftnsepc"
//          |   "cell"
//          |   "nestcell"
//          |   "row"
//          |   "nestrow"
//          |   "par"
//          |   "sect"
            |   "page"
            |   "column"
            |   "line"
            |   "lbr"
            |   "softpage"
            |   "softcol"
            |   "softline"
            |   "softlheight"
            |   "tab"
            |   "emdash"
            |   "endash"
            |   "emspace"
            |   "enspace"
            |   "qmspace"
            |   "bullet"
            |   "lquote"
            |   "rquote"
            |   "ldblquote"
            |   "rdblquote"
            |   "ltrmark"
            |   "rtlmark"
            |   "zwbo"
            |   "zwnbo"
            |   "zwj"
            |   "zwnj"
            |   hex_value
            |   ctrl_sym
            ;

unicode_represent
            : bgroup "upr" (rtf_char)* bgroup "ud" (rtf_char)* egroup egroup ;

unicode_char: "u" ;

bgroup      : BEGINGROUP ;
egroup      : ENDGROUP ;
semi        : SEMI ;
pcdata      : PCDATA ;
hex_value   : HEX_NUMBER ;
ctrl_sym    : CONTROL_SYM ;

/** Output Token
 *
 *  BEGINGROUP
 *  ENDGROUP
 *  SEMI
 *  PCDATA
 *  HEX_NUMBER
 */

/*
BEGINGROUP              : "{"
ENDGROUP                : "}"
NEWLINE                 : "\n" | "\r" | "\t"

NON_BREAKING_SPACE      : "\\~"
OPTIONAL_HYPHEN         : "\\-"
NON_BREAKING_HYPHEN     : "\\_"
IGNORABLE_DESTINATION   : "\\*"
FORMULA_CHARACTER       : "\\|"
INDEX_SUBENTRY          : "\\:"
ESCAPED_LBRACE          : "\\{"
ESCAPED_RBRACE          : "\\}"
ESCAPED_BACKSLASH       : "\\\\"
HEX_NUMBER              : "\\'"
CONTROL_WORD            : "\\"
CONTROL_SYM             : "\\" ~["a"-"z", "A"-"Z", "0"-"9", " ", "\n", "\r", "\t", "}", "{", "\\"]

TEXT                    : (~["\\","{","}","\n","\r", "\t"])+
HEX_DIGIT               : ["0"-"9","a"-"f","A"-"F"]
HEX_CHAR                : HEX_DIGIT HEX_DIGIT

ESCAPED_NEWLINE         : "\\\n"
ESCAPED_CARRIAGE_RETURN : "\\\r"
*/

class RTFLexer extends Lexer;

options {
    k               = 2;
    exportVocab     = RTF;
    testLiterals    = false;
    charVocabulary  = '\3'..'\177';
    filter          = true;
}

tokens {
//  FORMULA_CHARACTER;
//  INDEX_SUBENTRY;
//  NON_BREAKING_SPACE;
//  OPTIONAL_HYPHEN;
//  NON_BREAKING_HYPHEN;
//  ESCAPED_LBRACE;
//  ESCAPED_RBRACE;
//  ESCAPED_BACKSLASH;

//  HEX_NUMBER;
//  IGNORABLE_DESTINATION;
    CONTROL_WORD;
//  CONTROL_SYM;
}

{
    public RTFLexer(URL url) throws IOException {
        this(url.openStream());
    }

    Queue _tokenQueue = new LinkedList();
    Stack _tokenStack = new Stack();
    Hashtable _groupedLiterals = new Hashtable();

    private boolean enTokenQueue(int _tokenType, String _tokenText)
    {
        boolean _result = false;

        switch ( _tokenType )
        {
            case LITERAL_rtf:
            case LITERAL_fonttbl:
//          case LITERAL_f:
            case LITERAL_panose:
            case LITERAL_fname:
            case LITERAL_fontemb:
            case LITERAL_fontfile:
            case LITERAL_falt:
            case LITERAL_filetbl:
            case LITERAL_file:
            case LITERAL_colortbl:
            case LITERAL_stylesheet:
            case LITERAL_keycode:
            case LITERAL_listtable:
            case LITERAL_list:
            case LITERAL_listlevel:
            case LITERAL_leveltext:
            case LITERAL_levelnumbers:
            case LITERAL_listname:
            case LITERAL_listoverridetable:
            case LITERAL_listoverride:
            case LITERAL_lfolevel:
            case LITERAL_revtbl:
            case LITERAL_info:
            case LITERAL_title:
            case LITERAL_subject:
            case LITERAL_author:
            case LITERAL_manager:
            case LITERAL_company:
            case LITERAL_operator:
            case LITERAL_keywords:
            case LITERAL_category:
            case LITERAL_comment:
            case LITERAL_doccomm:
            case LITERAL_hlinkbase:
            case LITERAL_creatim:
            case LITERAL_revtim:
            case LITERAL_printim:
            case LITERAL_buptim:
            case LITERAL_version:
            case LITERAL_vern:
            case LITERAL_edmins:
            case LITERAL_nofpages:
            case LITERAL_nofwords:
            case LITERAL_nofchars:
            case LITERAL_nofcharsws:
            case LITERAL_id:
            case LITERAL_userprops:
            case LITERAL_propname:
            case LITERAL_staticval:
            case LITERAL_linkval:
            case LITERAL_docvar:
            case LITERAL_header:
            case LITERAL_footer:
            case LITERAL_headerl:
            case LITERAL_headerr:
            case LITERAL_headerf:
            case LITERAL_footerl:
            case LITERAL_footerr:
            case LITERAL_footerf:
            case LITERAL_pnseclvl:
            case LITERAL_pntext:
            case LITERAL_pn:
            case LITERAL_pntxtb:
            case LITERAL_pntxta:
            case LITERAL_shppict:
            case LITERAL_nonshppict:
            case LITERAL_pict:
            case LITERAL_picprop:
            case LITERAL_blipuid:
            case LITERAL_bin:
            case LITERAL_shp:
            case LITERAL_shpinst:
            case LITERAL_shprslt:
            case LITERAL_shptxt:
            case LITERAL_sp:
            case LITERAL_sn:
            case LITERAL_sv:
            case LITERAL_do:
            case LITERAL_dptxbxtext:
            case LITERAL_hl:
            case LITERAL_hlloc:
            case LITERAL_hlsrc:
            case LITERAL_hlfr:
            case LITERAL_listtext:
            case LITERAL_datafield:
            case LITERAL_footnote:
            case LITERAL_object:
            case LITERAL_objclass:
            case LITERAL_objname:
            case LITERAL_objtime:
            case LITERAL_objdata:
            case LITERAL_objalias:
            case LITERAL_objsect:
            case LITERAL_result:
            case LITERAL_atnid:
            case LITERAL_atnauthor:
            case LITERAL_atntime:
            case LITERAL_atnicn:
            case LITERAL_annotation:
            case LITERAL_atnref:
            case LITERAL_bkmkstart:
            case LITERAL_bkmkend:
            case LITERAL_atrfstart:
            case LITERAL_atrfend:
            case LITERAL_field:
            case LITERAL_fldinst:
            case LITERAL_fldrslt:
            case LITERAL_xe:
            case LITERAL_txe:
            case LITERAL_rxe:
            case LITERAL_tc:
            case LITERAL_tcn:
            case LITERAL_tcf:
            case LITERAL_tcl:
            case LITERAL_upr:
            case LITERAL_ud:
            {
                Token _token = makeToken(_tokenType);
                _token.setText(_tokenText);

                if ( !(_result = _tokenQueue.offer(_token)) )
                {
                    System.err.println("Token Queue error !");
                }

                break;
            }
        }

        return _result;
    }

    private Token deTokenQueue()
    {
        return (Token)_tokenQueue.poll();
    }

//  theRetToken = deTokenQueue();
//  if (theRetToken != null)
//      return theRetToken;

}

BEGINGROUP
{
    int _tokenType = Token.INVALID_TYPE;
}
            : '{'!  (   i:IGNORABLE_DEST!
                        (   { (LA(1)=='\\') && ((LA(2) >= 'a' && LA(2) <= 'z') || (LA(2) >= 'A' && LA(2) <= 'Z')) }? '\\'! w_1:WORD! (NUMBER!)? (' '!)?
                            {
                                _tokenType = testLiteralsTable(w_1.getText(), _tokenType);

                                if (!enTokenQueue(_tokenType, w_1.getText()))
                                {
//                                  {\*\ctrl_word -> \ctrl_word
                                    _tokenStack.push(new Integer(RTFTokenTypes.BEGINGROUP));
                                }
                                else
                                {
//                                  {\*\grouped_ctrl_word -> { + \ctrl_word
                                    _tokenStack.push(new Integer(_tokenType));
                                    _tokenType = RTFTokenTypes.BEGINGROUP;
                                }
                            }
                        )?
                    |   '\\'! w_2:WORD! (NUMBER!)? (' '!)?
                        {
                                _tokenType = testLiteralsTable(w_2.getText(), _tokenType);

                                if (!enTokenQueue(_tokenType, w_2.getText()))
                                {
//                                  {\ctrl_word -> \ctrl_word
                                    _tokenStack.push(new Integer(RTFTokenTypes.BEGINGROUP));
                                }
                                else
                                {
//                                  {\grouped_ctrl_word -> { + \ctrl_word
                                    _tokenStack.push(new Integer(_tokenType));
                                    _tokenType = RTFTokenTypes.BEGINGROUP;
                                }
                        }
                    )?
            {
                if (_tokenType != Token.INVALID_TYPE)
                {
                    _ttype = _tokenType;
                }
                else
                {
                    _tokenStack.push(new Integer(RTFTokenTypes.BEGINGROUP));
                    _ttype = Token.SKIP;
                }
            }
            ;

ENDGROUP    : '}'!
            {
                Integer _tokenType = (Integer)_tokenStack.pop();

                if (_tokenType.intValue() == RTFTokenTypes.BEGINGROUP)
                {
                    _ttype = Token.SKIP;
                }
            }
            ;

ESC_CHAR    :   '\\'!
            (   CTRL_LETTER
                {
                    $setType(CONTROL_SYM);
                }
            |   WORD (NUMBER!)? (' '!)?
                {
                    $setType(CONTROL_WORD);
                }
            |   ESC_LETTER
                {
                    $setType(PCDATA);
                }
//          |   '*'!
//              {
//                  $setType(IGNORABLE_DESTINATION);
//              }
            |   '\''! HEX_DIGIT HEX_DIGIT
                {
                    $setType(HEX_NUMBER);
                }
            )
            {
                if (_ttype == CONTROL_WORD)
                {
                    _ttype = testLiteralsTable(_ttype);
                }
            }
            ;

SEMI        : ';' ;
PCDATA      : LETTER | DIGIT | PUNCTUATION ;

CR          :   (   (   options { generateAmbigWarnings = false; }
                    :   "\r\n"  // Evil DOS
                    |   '\r'    // Macintosh
                    |   '\n'    // Unix (the right way)
                    )
                    { newline(); }
                )+
                { $setType(Token.SKIP); }
            ;

protected IGNORABLE_DEST: '\\' '*' ;
protected CTRL_LETTER   : '~' | '-' | '_' | '|' | ':' ;
protected ESC_LETTER    : '{' | '}' | '\\' ;
protected WORD          : ( LETTER )+ ;
protected NUMBER        : ('-')? ( DIGIT )+ ;
protected LETTER        : 'A'..'Z' | 'a'..'z' ;
protected DIGIT         : '0'..'9' ;
protected PUNCTUATION   :   '<'
                        |   '>'
                        |   '('
                        |   ')'
//                      |   '{'
//                      |   '}'
                        |   '['
                        |   ']'
                        |   '+'
                        |   '-'
                        |   '/'
//                      |   '\\'
                        |   '~'
                        |   '@'
                        |   '#'
                        |   '$'
                        |   '%'
                        |   '^'
                        |   '&'
                        |   '*'
                        |   '_'
                        |   '|'
                        |   '`'
                        |   '='
                        |   '\''
                        |   '"'
                        |   ','
                        |   '.'
                        |   ':'
//                      |   ';'
                        |   '?'
                        |   '!'
                        |   ' '
                        ;
protected HEX_DIGIT     : '0'..'9' | 'a'..'f' ;
