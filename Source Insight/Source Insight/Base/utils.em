/* Utils.em - a small collection of useful editing macros */



/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function. 
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)
	
	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "
	
	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}
	
	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2
	
	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")
	
	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function. 
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)
	
	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2
	
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}

	
// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and 
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}
	
	hbufOutput = NewBuf("Results")
	
	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}
		
	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)
	
	return hbufOutput

}

    /*======================================================================
    1��BackSpace���˼�
    ======================================================================*/
    macro SuperBackspace()
    {
        hwnd = GetCurrentWnd();
        hbuf = GetCurrentBuf();
        if (hbuf == 0)
            stop; // empty buffer
        // get current cursor postion
        ipos = GetWndSelIchFirst(hwnd);
        // get current line number
        ln = GetBufLnCur(hbuf);
        if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
            // sth. was selected, del selection
            SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight
            // del the " "
            SuperBackspace(1);
            stop;
        }
        // copy current line
        text = GetBufLine(hbuf, ln);
        // get string length
        len = strlen(text);
        // if the cursor is at the start of line, combine with prev line
        if (ipos == 0 || len == 0) {
            if (ln <= 0)
                stop; // top of file
            ln = ln - 1; // do not use "ln--" for compatibility with older versions
            prevline = GetBufLine(hbuf, ln);
            prevlen = strlen(prevline);
            // combine two lines
            text = cat(prevline, text);
            // del two lines
            DelBufLine(hbuf, ln);
            DelBufLine(hbuf, ln);
            // insert the combined one
            InsBufLine(hbuf, ln, text);
            // set the cursor position
            SetBufIns(hbuf, ln, prevlen);
            stop;
        }
        num = 1; // del one char
        if (ipos >= 1) {
            // process Chinese character
            i = ipos;
            count = 0;
            while (AsciiFromChar(text[i - 1]) >= 160) {
                i = i - 1;
                count = count + 1;
                if (i == 0)
                    break;
            }
            if (count > 0) {
                // I think it might be a two-byte character
                num = 2;
                // This idiot does not support mod and bitwise operators
                if ((count / 2 * 2 != count) && (ipos < len))
                    ipos = ipos + 1; // adjust cursor position
            }
        }
        // keeping safe
        if (ipos - num < 0)
            num = ipos;
        // del char(s)
        text = cat(strmid(text, 0, ipos - num), strmid(text, ipos, len));
        DelBufLine(hbuf, ln);
        InsBufLine(hbuf, ln, text);
        SetBufIns(hbuf, ln, ipos - num);
        stop;
    }
    /*======================================================================
    2��ɾ��������SuperDelete.em
    ======================================================================*/
    macro SuperDelete()
    {
        hwnd = GetCurrentWnd();
        hbuf = GetCurrentBuf();
        if (hbuf == 0)
            stop; // empty buffer
        // get current cursor postion
        ipos = GetWndSelIchFirst(hwnd);
        // get current line number
        ln = GetBufLnCur(hbuf);
        if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
            // sth. was selected, del selection
            SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight
            // del the " "
            SuperDelete(1);
            stop;
        }
        // copy current line
        text = GetBufLine(hbuf, ln);
        // get string length
        len = strlen(text);

        if (ipos == len || len == 0) {
    totalLn = GetBufLineCount (hbuf);
    lastText = GetBufLine(hBuf, totalLn-1);
    lastLen = strlen(lastText);
            if (ipos == lastLen)// end of file
       stop;
            ln = ln + 1; // do not use "ln--" for compatibility with older versions
            nextline = GetBufLine(hbuf, ln);
            nextlen = strlen(nextline);
            // combine two lines
            text = cat(text, nextline);
            // del two lines
            DelBufLine(hbuf, ln-1);
            DelBufLine(hbuf, ln-1);
            // insert the combined one
            InsBufLine(hbuf, ln-1, text);
            // set the cursor position
            SetBufIns(hbuf, ln-1, len);
            stop;
        }
        num = 1; // del one char
        if (ipos > 0) {
            // process Chinese character
            i = ipos;
            count = 0;
          while (AsciiFromChar(text[i-1]) >= 160) {
                i = i - 1;
                count = count + 1;
                if (i == 0)
                    break;
            }
            if (count > 0) {
                // I think it might be a two-byte character
                num = 2;
                // This idiot does not support mod and bitwise operators
                if (((count / 2 * 2 != count) || count == 0) && (ipos < len-1))
                    ipos = ipos + 1; // adjust cursor position
            }
    // keeping safe
    if (ipos - num < 0)
                num = ipos;
        }
        else {
    i = ipos;
    count = 0;
    while(AsciiFromChar(text) >= 160) {
         i = i + 1;
         count = count + 1;
         if(i == len-1)
       break;
    }
    if(count > 0) {
         num = 2;
    }
        }

        text = cat(strmid(text, 0, ipos), strmid(text, ipos+num, len));
        DelBufLine(hbuf, ln);
        InsBufLine(hbuf, ln, text);
        SetBufIns(hbuf, ln, ipos);
        stop;
    }
    /*======================================================================
    3�����Ƽ�����SuperCursorLeft.em
    ======================================================================*/
    macro IsComplexCharacter()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
       return 0;
    //��ǰλ��
    pos = GetWndSelIchFirst(hwnd);
    //��ǰ����
    ln = GetBufLnCur(hbuf);
    //�õ���ǰ��
    text = GetBufLine(hbuf, ln);
    //�õ���ǰ�г���
    len = strlen(text);
    //��ͷ���㺺���ַ��ĸ���
    if(pos > 0)
    {
       i=pos;
       count=0;
       while(AsciiFromChar(text[i-1]) >= 160)
       {
        i = i - 1;
        count = count+1;
        if(i == 0)
         break;
       }
       if((count/2)*2==count|| count==0)
        return 0;
       else
        return 1;
    }
    return 0;
    }
    macro moveleft()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
            stop; // empty buffer

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    if(GetBufSelText(hbuf) != "" || (ipos == 0 && ln == 0)) // ��0�л�����ѡ������,���ƶ�
    {
       SetBufIns(hbuf, ln, ipos);
       stop;
    }
    if(ipos == 0)
    {
       preLine = GetBufLine(hbuf, ln-1);
       SetBufIns(hBuf, ln-1, strlen(preLine)-1);
    }
    else
    {
       SetBufIns(hBuf, ln, ipos-1);
    }
    }
    macro SuperCursorLeft()
    {
    moveleft();
    if(IsComplexCharacter())
       moveleft();
    }
    /*======================================================================
    4�����Ƽ�����SuperCursorRight.em
    ======================================================================*/
    macro moveRight()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
            stop; // empty buffer
    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln);
    if(GetBufSelText(hbuf) != "") //ѡ������
    {
       ipos = GetWndSelIchLim(hwnd);
       ln = GetWndSelLnLast(hwnd);
       SetBufIns(hbuf, ln, ipos);
       stop;
    }
    if(ipos == strlen(text)-1 && ln == totalLn-1) // ĩ��
       stop;
    if(ipos == strlen(text))
    {
       SetBufIns(hBuf, ln+1, 0);
    }
    else
    {
       SetBufIns(hBuf, ln, ipos+1);
    }
    }
    macro SuperCursorRight()
    {
    moveRight();
    if(IsComplexCharacter()) // defined in SuperCursorLeft.em
       moveRight();
    }
    /*======================================================================
    5��shift+���Ƽ�����ShiftCursorRight.em
    ======================================================================*/
    macro IsShiftRightComplexCharacter()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
       return 0;
    selRec = GetWndSel(hwnd);
    pos = selRec.ichLim;
    ln = selRec.lnLast;
    text = GetBufLine(hbuf, ln);
    len = strlen(text);
    if(len == 0 || len < pos)
    return 1;
    //Msg("@len@;@pos@;");
    if(pos > 0)
    {
       i=pos;
       count=0;
       while(AsciiFromChar(text[i-1]) >= 160)
       {
        i = i - 1;
        count = count+1;
        if(i == 0)
         break;
       }
       if((count/2)*2==count|| count==0)
        return 0;
       else
        return 1;
    }
    return 0;
    }
    macro shiftMoveRight()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
            stop;

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln);
    selRec = GetWndSel(hwnd);
    curLen = GetBufLineLength(hbuf, selRec.lnLast);
    if(selRec.ichLim == curLen+1 || curLen == 0)
    {
       if(selRec.lnLast == totalLn -1)
        stop;
       selRec.lnLast = selRec.lnLast + 1;
       selRec.ichLim = 1;
       SetWndSel(hwnd, selRec);
       if(IsShiftRightComplexCharacter())
        shiftMoveRight();
       stop;
    }
    selRec.ichLim = selRec.ichLim+1;
    SetWndSel(hwnd, selRec);
    }
    macro SuperShiftCursorRight()
    {
    if(IsComplexCharacter())
       SuperCursorRight();
    shiftMoveRight();
    if(IsShiftRightComplexCharacter())
       shiftMoveRight();
    }
    /*======================================================================
    6��shift+���Ƽ�����ShiftCursorLeft.em
    ======================================================================*/
    macro IsShiftLeftComplexCharacter()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
       return 0;
    selRec = GetWndSel(hwnd);
    pos = selRec.ichFirst;
    ln = selRec.lnFirst;
    text = GetBufLine(hbuf, ln);
    len = strlen(text);
    if(len == 0 || len < pos)
       return 1;
    //Msg("@len@;@pos@;");
    if(pos > 0)
    {
       i=pos;
       count=0;
       while(AsciiFromChar(text[i-1]) >= 160)
       {
        i = i - 1;
        count = count+1;
        if(i == 0)
         break;
       }
       if((count/2)*2==count|| count==0)
        return 0;
       else
        return 1;
    }
    return 0;
    }
    macro shiftMoveLeft()
    {
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
            stop;

    ln = GetBufLnCur(hbuf);
    ipos = GetWndSelIchFirst(hwnd);
    totalLn = GetBufLineCount(hbuf);
    text = GetBufLine(hbuf, ln);
    selRec = GetWndSel(hwnd);
    //curLen = GetBufLineLength(hbuf, selRec.lnFirst);
    //Msg("@curLen@;@selRec@");
    if(selRec.ichFirst == 0)
    {
       if(selRec.lnFirst == 0)
        stop;
       selRec.lnFirst = selRec.lnFirst - 1;
       selRec.ichFirst = GetBufLineLength(hbuf, selRec.lnFirst)-1;
       SetWndSel(hwnd, selRec);
       if(IsShiftLeftComplexCharacter())
        shiftMoveLeft();
       stop;
    }
    selRec.ichFirst = selRec.ichFirst-1;
    SetWndSel(hwnd, selRec);
    }
    macro SuperShiftCursorLeft()
    {
    if(IsComplexCharacter())
       SuperCursorLeft();
    shiftMoveLeft();
    if(IsShiftLeftComplexCharacter())
       shiftMoveLeft();
    }
    /*---END---*/



    //magic-number:tph85666031

macro CodeComments(){//����ע��
 hwnd=GetCurrentWnd()
 selection=GetWndSel(hwnd)
 LnFirst=GetWndSelLnFirst(hwnd)//ȡ�����к�
 LnLast=GetWndSelLnLast(hwnd)//ȡĩ���к�
 hbuf=GetCurrentBuf()
 if(GetBufLine(hbuf,0)=="//magic-number:tph85666031"){
  stop
 }
 Ln=Lnfirst
 buf=GetBufLine(hbuf,Ln)
 len=strlen(buf)
 while(Ln<=Lnlast){
  buf=GetBufLine(hbuf,Ln)//ȡLn��Ӧ����
  if(buf==""){//��������
   Ln=Ln+1
   continue
  }
  if(StrMid(buf,0,1)=="/"){//��Ҫȡ��ע��,��ֹֻ�е��ַ�����
   if(StrMid(buf,1,2)=="/"){
   PutBufLine(hbuf,Ln,StrMid(buf,2,Strlen(buf)))
   }
  }
  if(StrMid(buf,0,1)!="/"){//��Ҫ���ע��
   PutBufLine(hbuf,Ln,Cat("//",buf))
  }
  Ln=Ln+1
 }
 SetWndSel( hwnd, selection )
}


macro MultiLineComment()

{

    hwnd = GetCurrentWnd()

    selection = GetWndSel(hwnd)

    LnFirst =GetWndSelLnFirst(hwnd)      //ȡ�����к�

    LnLast =GetWndSelLnLast(hwnd)      //ȡĩ���к�

    hbuf = GetCurrentBuf()

 

    if(GetBufLine(hbuf, 0) =="//magic-number:tph85666031"){

        stop

    }

 

    Ln = Lnfirst

    buf = GetBufLine(hbuf, Ln)

    len = strlen(buf)

 

    while(Ln <= Lnlast) {

        buf = GetBufLine(hbuf, Ln)  //ȡLn��Ӧ����

        if(buf ==""){                   //��������

            Ln = Ln + 1

            continue

        }

 

        if(StrMid(buf, 0, 1) == "/"){       //��Ҫȡ��ע��,��ֹֻ�е��ַ�����

            if(StrMid(buf, 1, 2) == "/"){

                PutBufLine(hbuf, Ln, StrMid(buf, 2, Strlen(buf)))

            }

        }

 

        if(StrMid(buf,0,1) !="/"){          //��Ҫ���ע��

            PutBufLine(hbuf, Ln, Cat("//", buf))

        }

        Ln = Ln + 1

    }

 

    SetWndSel(hwnd, selection)

}


// #if 0
macro AddMacroComment()

{

    hwnd=GetCurrentWnd()

    sel=GetWndSel(hwnd)

    lnFirst=GetWndSelLnFirst(hwnd)

    lnLast=GetWndSelLnLast(hwnd)

    hbuf=GetCurrentBuf()

 

    if (LnFirst == 0) {

            szIfStart = ""

    } else {

            szIfStart = GetBufLine(hbuf, LnFirst-1)

    }

    szIfEnd = GetBufLine(hbuf, lnLast+1)

    if (szIfStart == "#if 0" && szIfEnd =="#endif") {

            DelBufLine(hbuf, lnLast+1)

            DelBufLine(hbuf, lnFirst-1)

            //sel.lnFirst = sel.lnFirst �C 1

            //sel.lnLast = sel.lnLast �C 1

    } else {

            InsBufLine(hbuf, lnFirst, "#if 0")

            InsBufLine(hbuf, lnLast+2, "#endif")

            sel.lnFirst = sel.lnFirst + 1

            sel.lnLast = sel.lnLast + 1

    }

 

    SetWndSel( hwnd, sel )

}



macro CommentSingleLine()

{

    hbuf = GetCurrentBuf()

    ln = GetBufLnCur(hbuf)

str = GetBufLine (hbuf, ln)

    str = cat("/*",str)

    str = cat(str,"*/")

    PutBufLine (hbuf, ln, str)

}



macro CommentSelStr()

{

    hbuf = GetCurrentBuf()

    ln = GetBufLnCur(hbuf)

    str = GetBufSelText(hbuf)

    str = cat("/*",str)

    str = cat(str,"*/")

    SetBufSelText (hbuf, str)

}


    /******************************************************************************* 
    * Copyright (C), 2000-2010, Electronic Technology Co., Ltd. 
    * �ļ���: utils.em 
    * ��  ��: shangwx 
    * ��  ��: 
    * ��  ��: 2010-3-12     //������� 
    * ˵  ��: ����Source Insight�ĺꡣ 
    * 
    * �޶���ʷ: 
    *    1. ʱ��: 2010-3-12 
    *       �޶���: shangwx 
    *       �޶�����: ���� 
    *    2. 
    * ����: �뽫���ļ����Ƶ� �ҵ��ĵ�/Source Insight/Projects/Base������ԭ�е��ļ��� 
    *******************************************************************************/  
      
      
    /******************************************************************************* 
    * ��������: InsertSysTime 
    * ˵��:     ���뵱ǰϵͳʱ�� 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     ʱ���ʽ�磺2010-3-12 9:42:44 
    *******************************************************************************/  
    macro InsertSysTime()  
    {  
        hbufCur = GetCurrentBuf();  
        LocalTime = GetSysTime(1)  
      
        Year = LocalTime.Year  
        Month = LocalTime.Month  
        Day = LocalTime.Day  
        Time = LocalTime.time  
      
        SetBufSelText (hbufCur, "@Year@-@Month@-@Day@ @Time@")  
    }  
      
    /******************************************************************************* 
    * ��������: CloseFileWindows 
    * ˵��:     �ر������Ѵ򿪵��ļ� 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro CloseFileWindows()  
    {  
        cwnd = WndListCount()  
        iwnd = 0  
        while (1)  
        {  
            hwnd = WndListItem(0)  
            hbuf = GetWndBuf(hwnd)  
            SaveBuf(hbuf)  
            CloseWnd(hwnd)  
            iwnd = iwnd + 1  
            if(iwnd >= cwnd)  
            {  
                break  
            }  
        }  
    }  
      
    /******************************************************************************* 
    * ��������: InsertIf 
    * ˵��:     ����ѡ��������#if 0 / #endif 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     ������ѡ����� 
    *******************************************************************************/  
    macro InsertIf()  
    {  
        ProgEnvInfo = GetProgramEnvironmentInfo ()  
        Editor = ProgEnvInfo.UserName  
      
        hwnd = GetCurrentWnd()  
        lnFirst = GetWndSelLnFirst(hwnd)  
        lnLast = GetWndSelLnLast(hwnd)  
        LocalTime = GetSysTime(1)  
      
        Year = LocalTime.Year  
        Month = LocalTime.Month  
        Day = LocalTime.Day  
        Time = LocalTime.time  
        hbuf = GetCurrentBuf()  
        InsBufLine(hbuf, lnFirst, "#if 0")  
        InsBufLine(hbuf, lnLast+2, "#endif /* if 0. @Year@-@Month@-@Day@ @Time@ @Editor@ */")  
    }  
      
    /******************************************************************************* 
    * ��������: InsertIfdef 
    * ˵��:     ����ѡ��������#ifdef XXX / #endif 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro InsertIfdef()  
    {  
        sz = Ask("Enter ifdef condition:")  
        if (sz != "")  
            IfdefSz(sz);  
    }  
      
    /******************************************************************************* 
    * ��������: InsertIfndef 
    * ˵��:     ����ѡ��������#ifndef XXX / #endif 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro InsertIfndef()  
    {  
        sz = Ask("Enter ifdnef condition:")  
        if (sz != "")  
            IfndefSz(sz);  
    }  
      
    // Wrap ifdef <sz> .. endif around the current selection  
    macro IfdefSz(sz)  
    {  
        ProgEnvInfo = GetProgramEnvironmentInfo ()  
        Editor = ProgEnvInfo.UserName  
      
        hwnd = GetCurrentWnd()  
        lnFirst = GetWndSelLnFirst(hwnd)  
        lnLast = GetWndSelLnLast(hwnd)  
        LocalTime = GetSysTime(1)  
      
        Year = LocalTime.Year  
        Month = LocalTime.Month  
        Day = LocalTime.Day  
        Time = LocalTime.time  
        hbuf = GetCurrentBuf()  
        InsBufLine(hbuf, lnFirst, "#ifdef @sz@")  
        InsBufLine(hbuf, lnLast+2, "#endif /* ifdef @sz@.@Year@-@Month@-@Day@ @Time@ @Editor@ */")  
    }  
      
    macro IfndefSz(sz)  
    {  
        ProgEnvInfo = GetProgramEnvironmentInfo ()  
        Editor = ProgEnvInfo.UserName  
      
        hwnd = GetCurrentWnd()  
        lnFirst = GetWndSelLnFirst(hwnd)  
        lnLast = GetWndSelLnLast(hwnd)  
        LocalTime = GetSysTime(1)  
      
        Year = LocalTime.Year  
        Month = LocalTime.Month  
        Day = LocalTime.Day  
        Time = LocalTime.time  
        hbuf = GetCurrentBuf()  
        InsBufLine(hbuf, lnFirst, "#ifndef @sz@")  
        InsBufLine(hbuf, lnLast+2, "#endif /* ifndef @sz@.@Year@-@Month@-@Day@ @Time@ @Editor@ */")  
    }  
      
    /******************************************************************************* 
    * ��������: InsertComment 
    * ˵��:     ����ע�� 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     ��ʽ�磺/* ABCDEFG */  
    *******************************************************************************/  
    macro InsertComment()  
    {  
        sz = Ask("Enter Comment:")  
        if (sz != "")  
            CommentSz(sz);  
    }  
      
    macro CommentSz(sz)  
    {  
        hbufCur = GetCurrentBuf();  
        SetBufSelText (hbufCur, "/*@sz@*/")  
    }  
      
    // Delete the current line and appends it to the clipboard buffer  
    macro KillLine()  
    {  
        hbufCur = GetCurrentBuf();  
        lnCur = GetBufLnCur(hbufCur)  
        //hbufClip = GetBufHandle("Clipboard")  
        //AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))  
      
        hwnd = GetCurrentWnd ()  
        SelRec = GetWndSel (hwnd)  
        Cnt = SelRec.lnLast - SelRec.lnFirst + 1  
        while(Cnt--)  
        {  
            DelBufLine(hbufCur, SelRec.lnFirst)  
        }  
        SaveBuf (hbufCur)  
    }  
      
    /******************************************************************************* 
    * ��������: InsertFileHeader 
    * ˵��:     �ڵ�ǰ�ļ��ϲ����ļ�ͷע�� 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro InsertFileHeader()  
    {  
        hbuf = GetCurrentBuf()  
      
        ProgEnvInfo = GetProgramEnvironmentInfo ()  
        Author = ProgEnvInfo.UserName  
      
        LocalTime = GetSysTime(1)  
        Year = LocalTime.Year  
        Month = LocalTime.Month  
        Day = LocalTime.Day  
      
        szBufName = GetBufName (hbuf)  
        Len = strlen(szBufName)  
        FileName = ""  
        if( 0 != Len)  
        {  
            cch = Len  
            while ("//" !=  szBufName[cch])  
            {  
                cch = cch - 1  
            }  
      
            while(cch < Len)  
            {  
                cch = cch + 1  
                FileName = Cat(FileName, szBufName[cch])  
            }  
        }  
      
        lnFirst = 0  
        InsBufLine(hbuf, lnFirst++, "/*******************************************************************************")  
        InsBufLine(hbuf, lnFirst++, "* Copyright (C), 2000-@Year@,  Electronic Technology Co., Ltd.")  
        InsBufLine(hbuf, lnFirst++, "* �ļ���: @FileName@")  
        InsBufLine(hbuf, lnFirst++, "* ��  ��: @Author@")  
        InsBufLine(hbuf, lnFirst++, "* ��  ��:")  
        InsBufLine(hbuf, lnFirst++, "* ��  ��: @Year@-@Month@-@Day@     //�������")  
        InsBufLine(hbuf, lnFirst++, "* ˵  ��:          // ������ϸ˵���˳����ļ���ɵ���Ҫ���ܣ�������ģ��")  
        InsBufLine(hbuf, lnFirst++, "*                  // �����Ľӿڣ����ֵ��ȡֵ��Χ�����弰������Ŀ�")  
        InsBufLine(hbuf, lnFirst++, "*                  // �ơ�˳�򡢶����������ȹ�ϵ")  
        InsBufLine(hbuf, lnFirst++, "* �޶���ʷ:        // �޸���ʷ��¼�б�ÿ���޸ļ�¼Ӧ�����޸����ڡ��޸�")  
        InsBufLine(hbuf, lnFirst++, "*                  // �߼��޸����ݼ���")  
        InsBufLine(hbuf, lnFirst++, "*    1. ʱ��: @Year@-@Month@-@Day@")  
        InsBufLine(hbuf, lnFirst++, "*       �޶���: @Author@")  
        InsBufLine(hbuf, lnFirst++, "*       �޶�����: ����")  
        InsBufLine(hbuf, lnFirst++, "*    2.")  
        InsBufLine(hbuf, lnFirst++, "* ����:           // �������ݵ�˵����ѡ�")  
        InsBufLine(hbuf, lnFirst++, "*******************************************************************************/")  
      
        SetBufIns (hbuf, lnFirst,0)  
        Len = strlen(FileName)  
        if(("h" == tolower(FileName[Len-1])) && ("." == FileName[Len-2]))  
        {  
            FileName = toupper(FileName)  
            FileName[Len-2] = "_"  
            szDef = "_"  
            szDef = Cat(szDef,FileName)  
            szDef = Cat(szDef,"_")  
      
            ProgEnvInfo = GetProgramEnvironmentInfo ()  
            Editor = ProgEnvInfo.UserName  
      
            hwnd = GetCurrentWnd()  
            lnFirst = GetWndSelLnFirst(hwnd)  
            LocalTime = GetSysTime(1)  
      
            Year = LocalTime.Year  
            Month = LocalTime.Month  
            Day = LocalTime.Day  
            Time = LocalTime.time  
            hbuf = GetCurrentBuf()  
            InsBufLine(hbuf,lnFirst++,"#ifndef @szDef@")  
            InsBufLine(hbuf,lnFirst++,"#define @szDef@")  
            InsBufLine(hbuf,lnFirst++,"")  
            InsBufLine(hbuf,lnFirst++,"")  
            InsBufLine(hbuf,lnFirst++,"")  
            InsBufLine(hbuf,lnFirst++,"#endif /* ifndef @szDef@.@Year@-@Month@-@Day@ @Time@ @Editor@ */")  
        }  
        SaveBuf (hbuf)  
    }  
      
    /******************************************************************************* 
    * ��������: InsertFunctionHeader 
    * ˵��:     ���뺯����ͷע�� 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro InsertFunctionHeader()  
    {  
        hbuf = GetCurrentBuf()  
        lnFirst = GetBufLnCur(hbuf)  
        FuncName = GetCurSymbol()  
    /* 
        szLine = GetBufLine (hbuf, lnFirst) 
        Len = strlen(szLine) 
        FuncName = "" 
        if( 0 != Len) 
        { 
            cch = 0 
            while ("(" !=  szLine[cch]) 
            { 
                cch = cch + 1 
            } 
     
            while((" " == szLine[cch-1]) || ("  " == szLine[cch-1])) 
            { 
                cch = cch - 1 
            } 
            cch = cch - 1 
            ichLast = cch 
     
            while((" " != szLine[cch]) && ("    " != szLine[cch]) && ("*" != szLine[cch])) 
            { 
                cch = cch - 1 
            } 
            ichFirst = cch 
     
            while(ichFirst < ichLast) 
            { 
                ichFirst = ichFirst + 1 
                FuncName = Cat(FuncName, szLine[ichFirst]) 
            } 
        } 
    */  
        InsBufLine(hbuf, lnFirst++, "/*******************************************************************************")  
        InsBufLine(hbuf, lnFirst++, "* ��������: @FuncName@      // �������ơ�")  
        InsBufLine(hbuf, lnFirst++, "* ˵��:          // �������ܡ����ܵȵ�������")  
        InsBufLine(hbuf, lnFirst++, "* �������:      // �������˵��������ÿ������������ ")  
        InsBufLine(hbuf, lnFirst++, "*                // �á�ȡֵ˵�����������ϵ�� ")  
        InsBufLine(hbuf, lnFirst++, "* �������:      // �����������˵����")  
        InsBufLine(hbuf, lnFirst++, "* ����ֵ:        // ��������ֵ��˵����")  
        InsBufLine(hbuf, lnFirst++, "* ����:          // ����˵����ѡ���")  
        InsBufLine(hbuf, lnFirst++, "*******************************************************************************/")  
      
        SaveBuf (hbuf)  
    }  
      
    /******************************************************************************* 
    * ��������: DelPpIf 
    * ˵��:     ɾ��Ԥ����ָ��if/ifndef/ifdef ... endif 
    * �������: ��  
    * �������: �� 
    * ����ֵ:   �� 
    * ����:     �� 
    *******************************************************************************/  
    macro DelPpIf()  
    {  
        hbuf = GetCurrentBuf()  
        lnFirst = GetBufLnCur(hbuf)  
        lnIf = GetIfLine(hbuf,lnFirst)  
        lnEndif = GetEndifLine(hbuf,lnFirst)  
    //  Msg("IF:@lnIf@,END:@lnEnd@")  
      
        if((-1 == lnIf) || (-1 == lnEndif))  
        {  
            return 0  
        }  
        DelBufLine(hbuf,lnIf)  
        DelBufLine(hbuf,lnEndif-1)  
    }  
      
    macro GetIfLine(hBuf,Ln)  
    {  
        Start = Ln  
        Count = 1  
      
        while(Ln > 0)  
        {  
            szLn = GetBufLine(hBuf,Ln)  
      
            i = 0  
            while((" " == szLn[i]) || ("    " == szLn[i]))  
            {  
                i = i + 1  
            }  
            szRet = ""  
            while("" != szLn[i])  
            {  
                szRet = Cat(szRet,szLn[i])  
                i = i + 1  
            }  
            szLn = szRet  
            if(4 > strlen(szLn))  
            {  
                Ln = Ln - 1  
                continue  
            }  
            if(("#" == szLn[0]) && ("i" == szLn[1]) && ("f" == szLn[2]))  
            {  
                Count = Count - 1  
                if(0 >= Count)  
                {  
                    return(Ln)  
                }  
            }  
            else  
            {  
                if(("#" == szLn[0]) && ("e" == szLn[1]) && ("n" == szLn[2]) && ("d" == szLn[3]))  
                {  
                    if(Start != Ln)  
                    {  
                        Count = Count + 1  
                    }  
                }  
            }  
            Ln = Ln - 1  
        }  
        return -1  
    }  
      
    macro GetEndifLine(hBuf,Ln)  
    {  
        Start = Ln  
        Count = 1  
        lnCnt = GetBufLineCount (hBuf)  
      
        while(Ln < lnCnt)  
        {  
            szLn = GetBufLine(hBuf,Ln)  
            i = 0  
            while((" " == szLn[i]) || ("    " == szLn[i]))  
            {  
                i = i + 1  
            }  
            szRet = ""  
            while("" != szLn[i])  
            {  
                szRet = Cat(szRet,szLn[i])  
                i = i + 1  
            }  
      
            szLn = szRet  
            if(4 > strlen(szLn))  
            {  
                Ln = Ln + 1  
                continue  
            }  
            if(("#" == szLn[0]) && ("e" == szLn[1]) && ("n" == szLn[2]) && ("d" == szLn[3]))  
            {  
                Count = Count - 1  
                if(0 >= Count)  
                {  
                    return(Ln)  
                }  
            }  
            else  
            {  
                if(("#" == szLn[0]) && ("i" == szLn[1]) && ("f" == szLn[2]))  
                {  
                    if(Start != Ln)  
                    {  
                        Count = Count + 1  
                    }  
                }  
            }  
            Ln = Ln + 1  
        }  
        return -1  
    }  

//Ϊ��ָ����ݼ���
//Step 1�������ϴ��븴�Ʋ�����Ϊ�ļ�utils.em��Ȼ���临�Ƶ����ҵ��ĵ�/Source Insight/Projects/Base ������ԭ�е��ļ���
//Step 2��Option-��Key Assignments
//Step 3����Command�����ҵ���Ҫ�ĺ꣬��� Assign New Key��ָ����ݼ����������������ΪSource Insight�е���������ָ����ݼ�����

