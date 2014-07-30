    

$inf= $ARGV[0];
    open(INPUT,"<$inf") ||     ##  input file
        die "Can't input $inf $!";

$inf1= $ARGV[1];    ## stop word file
    open(STOPWORD_BNC,"<$inf1") ||
        die "Can't input $inf1 $!"; 

$outf=$ARGV[2]; #  PairWord file
    open(OUTPUT,">$outf") ||
        die "Can't output $outf $!";

$outf1=$ARGV[3]; #  cleanText file
    open(OUTFILE,">$outf1") ||
        die "Can't output $outf1 $!";

my  %mdimHash = ();

 my $main_string;

 my %hash=();
 while ($string=<STOPWORD_BNC>)    
  {	
	@token=FindToken($string);
	$hash{@token[0]}=1;
	#print "Pass A == Loading stopwords.. line $x\n";
   }


while ($main_string=<INPUT>)    
{
	my @W; 		## array to contain word_sim value of w_ij
	my @M; 		## array to contain mean of b words
	my @D; 		## array to contain mean-std of b words

	@token=FindToken($main_string);
	@token=RefineToken3(@token);
	my $x=0;
	my @str;
	foreach $tok (@token)
	{	$tok=lc $tok;
		if ($hash{$tok} ==0)
		{
			push(@str,$tok);
			print OUTFILE "$tok ";	
			
		}

	}
	print OUTFILE "\n";

	#my @str=FindToken($main_string);
	my $bb=$#str + 1; 		##array size $bb is like the `b' var in paper
	
	################################## START  Algo 1 (storing) of doc_sim paper################
	my $i=0;
	my $k=0;
	my $l=0;
	while ($i<$bb-1)
	{
		$k++;
		$j=$k;

		my $str1=@str[$i];		## "car ";
		
		while ($j<$bb)
		{
			my $str2=@str[$j];		##"vehicle ";
				
				if (not (exists $mdimHash{$str1}{$str2} || exists $mdimHash{$str2}{$str1}) && ($str1 ne $str2))
				{ 
				
					$mdimHash{$str1}{$str2} = 1;
					
				} 
				
			$j++;
			$l++;	
		}
		$i++;
	}

  }

	for my $k1 (keys(%mdimHash)) 
	{  for my $k2 (keys(%{ $mdimHash{$k1} })) 
   		{    print OUTPUT "$k1 $k2\n";  
   		}
   
	}
my  %mdimHash = ();

####################################################
####################################################
sub FindToken 
{	my($str)=@_;
	my(@token);
	my $i=0;
    	while ($str=~/\S+/g)
		{
			$tok=$&;
			@token[$i]=$tok;
			$i++;
		}	
	
 	return @token;
}

#####################################################

sub RefineToken3 
{
	my(@token) = @_;	
	my(@reftoken);
	$i=0;
	foreach $tok (@token)
	{	
		if ($tok =~ /(([^-('&;]*)-([^-&,:.;)']*)?-?([^-&,:.;)']*)?-?([^-&,:.;)']*)?)/g)
		{	
			
			if ($2 ne ""){$tok=$2;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($3 ne ""){$tok=$3;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($4 ne ""){$tok=$4;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($5 ne ""){$tok=$5;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}

			#if ($2 ne "") { $tok=$2;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($3 ne "") { $tok=$3;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($4 ne "") { $tok=$4;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($5 ne "") { $tok=$5;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			
		}	
		
		
		elsif ($tok =~ /(([^\/(']*)\/([^\/&,:.;)']*)?\/?([^\/&,:.;)']*)?\/?([^\/&,:.;)']*)?)/g)
		{
			if ($2 ne ""){$tok=$2;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($3 ne ""){$tok=$3;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($4 ne ""){$tok=$4;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($5 ne ""){$tok=$5;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			#if ($2 ne "") { $tok=$2;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($3 ne "") { $tok=$3;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($4 ne "") { $tok=$4;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($5 ne "") { $tok=$5;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			
			
		}
		elsif ($tok =~ /(([^&]*)?&[a-zA-Z]*;([^,.:'&]*)?&?([^,.:';]*)?;?([^,.:';&]*)?)/g)
		{
			if ($2 ne ""){$tok=$2;
					if ($tok=~s/^([^!?.,:']+)[!?.,:']$/$1/) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
					elsif (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($3 ne ""){$tok=$3;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}
			if ($5 ne ""){$tok=$5;if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}


			#if ($2 ne "") { $tok=$2;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($3 ne "") { $tok=$3;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($4 ne "") { $tok=$4;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			#if ($5 ne "") { $tok=$5;$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}
			
			
		}


		else 
		{ 	$tok=~s/[^a-zA-Z]+.*[^a-zA-Z]+|[^a-zA-Z0-9]+(.*)|([a-zA-Z]+)'.*|\b[^ai]\b/$1$2/i;
			
			if ($tok ne ""){if (!($tok=~s/^[^aAiI]{1}$|^[0-9]+$|[^a-zA-z.]+//)) {
					$tok=~tr/A-Z/a-z/;@reftoken[$i]=$tok;$i++;}}			
			#if ($tok ne "")	{ $tok=~tr/A-Z/a-z/; @reftoken[$i]=$tok; $i++;}
		}

	}

 	return @reftoken;
}
###############################################################