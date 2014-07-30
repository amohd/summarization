
## Perl long_text...pl cleanText.txt pairWord.txt pairSimValue.txt top_number_of_words sorted.txt
#############################################################################
	

my $main_string;
 
#############################################################################

my $inputf= $ARGV[0];   ####"in1.txt";

	open(INPUT,"<$inputf") ||
        die "Can't input $inputf $!";

my $inSimValue= $ARGV[2];   ####"in1.txt";

	open(SIMV,"<$inSimValue") ||
        die "Can't input $inSimValue $!";
my @simv;
while ($str=<SIMV>)    
  {	
	my @tok=FindToken($str);
	push(@simv,@tok[0]);

   }


close(SIMV);




#my $top_n= $ARGV[3];   ####top_number_of_words to print
#$top_n=$top_n-1;
	

my $outf= $ARGV[3];   ####"out.txt";
	    $mode=">";
   		open(PAIRSIM,"$mode$outf") ||
        	die "Can't output $outf $!";
################################
### this module assign all simPair from pairSim.txt file in 2 D hash
#$inf1= "pairSim.txt"; 

$inf1= $ARGV[1];  
                           ## PairSim file open to read
    open(SIMI,"<$inf1") ||
       die "Can't input $inf1 $!";

my  %mdimHash = ();
 $x=0;
 ##my $xxx=1;
my $count=0;
 while ($string=<SIMI>)    
  {	
	@token=FindToken($string);
	$mdimHash{@token[0]}{@token[1]} = @simv[$count];
	$count++;
	$x++;
	##if ($x == $xxx*500000)
	###{print "BiG $x\n"; $xxx++;}
   }

close(SIMI);
##########################################################

my $main_string;

while ($main_string=<INPUT>)    
{
	my @W; 		## array to contain word_sim value of w_ij
	my @M; 		## array to contain mean of b words
	my @D; 		## array to contain mean-std of b words
	my @str=FindToken($main_string);
	my $bb=$#str + 1; 		##array size $bb is like the `b' var in paper
	
	################################## START  Algo 1 (storing) of doc_sim paper################
	my $i=0;
	my $k=0;
	my $l=0;
	
	if ($bb==0 || $bb==1)
	{ print PAIRSIM "@str[0] \n";}
	else
	{

	while ($i<$bb-1)
	{

		$k++;
		$j=$k;

		my $str1=@str[$i];		## "car ";
		
		while ($j<$bb)
		{
			my $str2=@str[$j];		##"vehicle ";
				
					
			
			if ($mdimHash{$str1}{$str2})
			{	$W[$l]= $mdimHash{$str1}{$str2}; }
			else {$W[$l]= $mdimHash{$str2}{$str1};} 

		
		
			$j++;
			$l++;	
					
	
		}
		$i++;
#print "$i\n";
	}
	################################## END Algo 1 (storing) of doc_sim paper################

##print "Sim Val = @W\n";

	################################## START Algo 2 (mean cal) of doc_sim paper################

	my $i=0;
	while ($i<$bb)
	{
		my $j=0;
		my $sum=0;
		while ($j<$bb)
		{
			my $wij=0;
			if ($j>$i)
			{
				$wij=$W[$i*($bb-1)-($i)*($i+1)/2+$j-1];
			} 
			else 
			{
				if ($i>$j)
				{
					$wij=$W[$j*($bb-1)-($j)*($j+1)/2+$i-1];
				}	
			}
			$sum=$sum+$wij;
			$j++;
				
		}

		$M[$i]=sprintf ("%.2f",$sum/($bb-1));  ## it was $bb-1
		$i++;
	}

	################################## END Algo 2 (mean cal) of doc_sim paper################
##print "Mean = @M\n";

	################################## START Algo 3 (mean-std cal) of doc_sim paper################
	my $i=0;
	while ($i<$bb)
	{
		my $j=0;
		my $sum=0;
		while ($j<$bb)
		{
			my $wij=0;
			if ($j>$i)
			{
				$wij=$W[$i*($bb-1)-($i)*($i+1)/2+$j-1];
				$sum=$sum+($wij-$M[$i])*($wij-$M[$i]);
			} 
			else 
			{
				if ($i>$j)
				{
					$wij=$W[$j*($bb-1)-($j)*($j+1)/2+$i-1];
					$sum=$sum+($wij-$M[$i])*($wij-$M[$i]);
				}	
			}
			
			$j++;
				
		}
		$D[$i]=sprintf ("%.2f",$M[$i]+sqrt($sum/($bb-1))); #### Need to replace + by -    ## it was $bb-1
		$i++;
	}


	################################## START Algo 3 (mean-std cal) of doc_sim paper################
##print "Diff= @D\n";

	################################# START Algo sorting words based on (mean-std) #############################
my %DD;	
for($i=0; $i<=$#D; $i++)  			#### Need to replace M by D 
{
  for($j=0; $j<2; $j++)
  {
        if (not (exists $DD{$str[$i]})) 
		{$DD{$str[$i]}=$D[$i];}
	 

	
  }
}

while( my( $key, $value ) = each %DD ){
    print PAIRSIM "$key $value\n";
}

print PAIRSIM "\n";

} # end of top else

				

	################################# END  Algo sorting words based on (mean-std)  #############################
	###################################################################################
	
} 			## end of while ($main_string=<INPUT>)  

###########################################################################################

######################## PROCEDURES #######################################################
sub FindToken 
{	my($str)=@_;
	my(@token);
	my $idi=0;
    	while ($str=~/\S+/g)
		{
			my $tok=$&;
			@token[$idi]=$tok;
			$idi++;
		}	
	
 	return @token;
}
########################################################################
