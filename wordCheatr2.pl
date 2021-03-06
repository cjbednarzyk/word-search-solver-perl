$ctFoundWord=0;

# Gather User Input
while(!(-f $inputFilename)) {
  system('cls');
  print "Word Cheatr\n";
  print " \n";
  print "Please type in the name of the text file that you wish to search\n";
  $inputFilename=<>;
  chomp $inputFilename;
}


# Gather File Data
$colLen=0;
$lineCt=0;
$wordSearchString='';
open(InputFile,"<$inputFilename");
while(<InputFile>) {
  $lineCt++;
  $currLine=$_;
  chomp $currLine;
  $currLine = uc $currLine;

  if($colLen==0) {
    $colLen = length $currLine;
  }
  elsif($colLen > length $currLine) {
    die("Line $lineCt in file $inputFilename is shorter than the other lines.\nPlease ensure that this line is $colLen characters wide!\n");
  }
  elsif($colLen < length $currLine) {
    die("Line $lineCt in file $inputFilename is longer than the other lines.\nPlease ensure that the other lines are ".(length $currLine)."characters wide!\n");
  }
  $wordSearchString.=$currLine;
}
close(InputFile);

while(($wordSearch eq '')||($wordSearch ne 'SEARCH')) {
  system('cls');
  print "Please type in the word(s) that you want wordCheatr to find or specify the document with the word(s) that you want wordCheatr to find\nPlease type SEARCH to start searching...\n";
  $wordSearch=<>;
  chomp $wordSearch;
  $wordSearch = uc $wordSearch;
  if(($wordSearch ne '') && ($wordSearch ne 'SEARCH')) {
    push @wordSearch, $wordSearch;
  }
}

open (OutputFile,">Results.txt");
# Clear the results file
close(OutputFile);

for($idxWordSearch=0;$idxWordSearch<=$#wordSearch;$idxWordSearch++) {
  if(-f $wordSearch[$idxWordSearch]) {
    open(WordListFile,"<$wordSearch[$idxWordSearch]");
    while(<WordListFile>) {
      $searchWord=$_;
      chomp $searchWord;
      $searchWord = uc $searchWord;
      &searchForWord($searchWord);
    }
    close(WordListFile);
  }
  else {
    &searchForWord($wordSearch[$idxWordSearch]);
  }
}

sub searchForWord {

  $wordToSearch = join ' ', @_;
  $ctFoundWord = 0;

  # Initialize array with blanks...
  for$outerloop (1..$lineCt) {
    for$innerloop (1..$colLen) {
      $wordsFound[$outerloop][$innerloop]='';
    }
  }

  # Words can be no longer than the number of columns or the number of rows in the rectangle of letters...
  if($colLen<$lineCt) {
    $minWidthHeight=$colLen;
  }
  else {
    $minWidthHeight=$lineCt;
  }

  # Find words horizontally (and backwards)
  for($idxRows=0;$idxRows<$lineCt;$idxRows++) {
    $currRow=substr($wordSearchString,($idxRows*$colLen),$colLen);
    $currReverseRow = reverse $currRow;

    $currPos=-1;
    $currPos = index($currRow, $wordToSearch, $currPos);
    while ($currPos != -1) {
      $ctFoundWord++;
#      print "Wordcheatr found Horizontal word $wordToSearch in $inputFilename at Row ".($idxRows+1).", Column ".($currPos+1)."\n";
      $wordsFound[$idxRows+1][$currPos+1].="Horizontal\t";
      $currPos++;
      $currPos = index($currRow,$wordToSearch,$currPos);
    }

    $currPos=-1;
    $currPos = index($currReverseRow, $wordToSearch, $currPos);
    while ($currPos != -1) {
      $ctFoundWord++;
#      print "Wordcheatr found Backwards word $wordToSearch in $inputFilename at Row ".($idxRows+1).", Column ".($colLen - $currPos)."\n";
      $wordsFound[$idxRows+1][$colLen - $currPos].="Backwards\t";
      $currPos++;
      $currPos = index($currReverseRow,$wordToSearch,$currPos);
    }
  }

  # Find words vertically (and upside-down)
  for($idxCols=0;$idxCols<$colLen;$idxCols++) {
    $currCol='';
    for($idxRows=0;$idxRows<$lineCt;$idxRows++) {
      $currCol.=substr($wordSearchString,($idxRows*$colLen)+$idxCols,1);
    }
    $currReverseCol = reverse $currCol;

    $currPos=-1;
    $currPos = index($currCol, $wordToSearch, $currPos);
    while ($currPos != -1) {
      $ctFoundWord++;
#      print "Wordcheatr found Vertical word $wordToSearch in $inputFilename at Row ".($currPos+1).", Column ".($idxCols+1)."\n";
      $wordsFound[$currPos+1][$idxCols+1].="Vertical\t";
      $currPos++;
      $currPos = index($currCol,$wordToSearch,$currPos);
    }

    $currPos=-1;
    $currPos = index($currReverseCol, $wordToSearch, $currPos);
    while ($currPos != -1) {
      $ctFoundWord++;
#      print "Wordcheatr found Upside-Down word $wordToSearch in $inputFilename at Row ".($lineCt - $currPos).", Column ".($idxCols+1)."\n";
       $wordsFound[$lineCt - $currPos][$idxCols+1].="Upside-Down\t";
      $currPos++;
      $currPos = index($currReverseCol,$wordToSearch,$currPos);
    }
  }

  # Find words diagonally down-rightward (and up-leftward)
  for($idxStartCol=0;$idxStartCol<$colLen;$idxStartCol++) {
    for($idxStartRow=0;$idxStartRow<$lineCt;$idxStartRow++) {
      $currDiag='';
      for($idxCurrPos=0;$idxCurrPos<$minWidthHeight;$idxCurrPos++) {
        $idxCols=$idxStartCol+$idxCurrPos;
        $idxRows=$idxStartRow+$idxCurrPos;
        if(($idxCols>=$colLen)||($idxRows>=$lineCt)) {
          last;
        }
        $currDiag.=substr($wordSearchString,($idxRows*$colLen)+$idxCols,1);
      }
      $currReverseDiag = reverse $currDiag;

      $currPos=-1;
      $currPos = index($currDiag, $wordToSearch, $currPos);
      while ($currPos != -1) {
        $ctFoundWord++;
#        print "Wordcheatr found Down-Right Diagonal word $wordToSearch in $inputFilename at Row ".($idxStartRow+$currPos+1).", Column ".($idxStartCol+$currPos+1)."\n";
        $wordsFound[$idxStartRow+$currPos+1][$idxStartCol+$currPos+1].="Down-Right Diagonal\t";
        $currPos++;
        $currPos = index($currDiag,$wordToSearch,$currPos);
      }

      $currPos=-1;
      $currPos = index($currReverseDiag, $wordToSearch, $currPos);
      while ($currPos != -1) {
        $ctFoundWord++;
#        print "Wordcheatr found Up-Left Diagonal word $wordToSearch in $inputFilename at Row ".($idxStartRow+(length $currDiag)-$currPos).", Column ".($idxStartCol+(length $currDiag)-$currPos)."\n";
        $wordsFound[$idxStartRow+(length $currDiag)-$currPos][$idxStartCol+(length $currDiag)-$currPos].="Up-Left Diagonal\t";
        $currPos++;
        $currPos = index($currReverseDiag,$wordToSearch,$currPos);
      }

      if($idxStartCol!=0) {
        last;
      }
    }
  }

  # Find words diagonally down-leftward (and up-rightward)
  for($idxStartCol=$colLen-1;$idxStartCol>-1;$idxStartCol--) {
    for($idxStartRow=0;$idxStartRow<$lineCt;$idxStartRow++) {
      $currDiag='';
      for($idxCurrPos=0;$idxCurrPos<$minWidthHeight;$idxCurrPos++) {
        $idxCols=$idxStartCol-$idxCurrPos;
        $idxRows=$idxStartRow+$idxCurrPos;
        if(($idxCols<0)||($idxRows>$lineCt)) {
          last;
        }
        $currDiag.=substr($wordSearchString,($idxRows*$colLen)+$idxCols,1);
      }
      $currReverseDiag = reverse $currDiag;

      $currPos=-1;
      $currPos = index($currDiag, $wordToSearch, $currPos);
      while ($currPos != -1) {
        $ctFoundWord++;
#        print "Wordcheatr found Down-Left Diagonal word $wordToSearch in $inputFilename at Row ".($idxStartRow+$currPos+1).", Column ".($idxStartCol-$currPos+1)."\n";
        $wordsFound[$idxStartRow+$currPos+1][$idxStartCol-$currPos+1].="Down-Left Diagonal\t";
        $currPos++;
        $currPos = index($currDiag,$wordToSearch,$currPos);
      }

      $currPos=-1;
      $currPos = index($currReverseDiag, $wordToSearch, $currPos);
      while ($currPos != -1) {
        $ctFoundWord++;
#        print "Wordcheatr found Up-Right Diagonal word $wordToSearch in $inputFilename at Row ".($idxStartRow+(length $currDiag)-$currPos).", Column ".($idxStartCol-(length $currDiag)+$currPos)."\n";
        $wordsFound[$idxStartRow+(length $currDiag)-$currPos][(length $currDiag)-$idxStartCol+$currPos].="Up-Right Diagonal\t";
        $currPos++;
        $currPos = index($currReverseDiag,$wordToSearch,$currPos);
      }

      if($idxStartCol<($colLen-1)) {
        last;
      }
    }
  }

  # Report Findings...

  print "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
  print "Input Filename:         $inputFilename\n";
  print "Word Being Located:     $wordToSearch\n";
  print "Number of Words Found:  $ctFoundWord\n";
  print "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
  print "Row\tColumn\tDirection\n----------------------------------------\n";
  for$outerloop (1..$lineCt) {
    for$innerloop (1..$colLen) {
      $currWordStart=$wordsFound[$outerloop][$innerloop];
      if($currWordStart ne '') {
        $currWordStart=substr($currWordStart,0,(length $currWordStart)-1);
        @currWordStart=split /\t/,$currWordStart;
        for($idxWords=0;$idxWords<=$#currWordStart;$idxWords++) {
          print "$outerloop\t$innerloop\t$currWordStart[$idxWords]\n";
        }
      }
    }
  }

  open (OutputFile,">>Results.txt");
  print OutputFile "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
  print OutputFile "Input Filename:         $inputFilename\n";
  print OutputFile "Word Being Located:     $wordToSearch\n";
  print OutputFile "Number of Words Found:  $ctFoundWord\n";
  print OutputFile "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
  print OutputFile "Row\tColumn\tDirection\n----------------------------------------\n";
  for$outerloop (1..$lineCt) {
    for$innerloop (1..$colLen) {
      $currWordStart=$wordsFound[$outerloop][$innerloop];
      if($currWordStart ne '') {
        $currWordStart=substr($currWordStart,0,(length $currWordStart)-1);
        @currWordStart=split /\t/,$currWordStart;
        for($idxWords=0;$idxWords<=$#currWordStart;$idxWords++) {
          print OutputFile "$outerloop\t$innerloop\t$currWordStart[$idxWords]\n";
        }
      }
    }
  }
  close(OutputFile);
}