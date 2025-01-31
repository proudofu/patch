function findpaths(neuron1,neuron2,max_hops)
%FINDPATHS(neuron1,neuron2,max_hops)
%
%find all one or two hop pathways from neuron1 to neuron2
%in maxhops or fewer hops  (maxhops cannot exceed 4)
%
%.if particular left or right suffix is not specified in neuron names,
%the search will be performed for all possible L/R combinations
%
%example: findpaths('ASH','AWC');
%will give pathways for ASHL->AWCL, ASHR->ASHR, ASHR->AWCL, and ASHL->AWCR
%
%.synapses can only be traversed in one direction, gap junctions in either
%
%.needs NeuronConnect.xls in same directory (get latest from WormAtlas.org)
%
%Saul Kato
%101201
%

if nargin<3
    max_hops=3;
end

if nargin<1
    neuron1='AWCL';
    neuron2='AIAL';
end



verblist={'syn','syp','gap'};
%load database
[num,txt,raw] = xlsread('NeuronConnect.xls','','','basic');
disp(' ');
disp(['FINDING PATHS FOR ' neuron1 ' -> ' neuron2 ', max ' num2str(max_hops) ' hops.']);
disp('(syn=synapse, syp=polyadic synapse, gap=gap junction)');
disp(' ');

%preprocess database
txt(1,:)=[];  %delete header
numrows=size(num,1);
verb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'S')  
        verb(i)=1;
    elseif strcmp(txt{i,3},'Sp')
        verb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        verb(i)=3;
    end
end

reverb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'R')  
        reverb(i)=1;
    elseif strcmp(txt{i,3},'Rp')
        reverb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        reverb(i)=3;
    end
end

neuron1L=[neuron1 'L'];
neuron2L=[neuron2 'L'];
neuron1R=[neuron1 'R'];
neuron2R=[neuron2 'R'];

for i=1:numrows
    if strcmp(txt(i,1),neuron1)
        firstneuron={neuron1}; break;
    else
        firstneuron={};
    end
end

for i=1:numrows
    if strcmp(txt(i,1),neuron2)
        secondneuron={neuron2}; break;
    else
        secondneuron={};
    end
end
        
t=0;
for i=1:numrows
    if strcmp(txt(i,1),neuron1L)
        firstneuron={firstneuron{:}, neuron1L}; break
    end
end

for i=1:numrows
     if strcmp(txt(i,1),neuron1R)
        firstneuron={firstneuron{:}, neuron1R}; break
    end
end   
 
for i=1:numrows
     if strcmp(txt(i,1),neuron1L)
        secondneuron={secondneuron{:}, neuron2L}; break
    end
end   

for i=1:numrows
     if strcmp(txt(i,1),neuron1R)
        secondneuron={secondneuron{:}, neuron2R}; break
    end
end   


for ii=1:length(firstneuron)
    for jj=1:length(secondneuron)
        disp(' ');
        disp('------------------------------');
        disp(['||       ' firstneuron{ii} ' -> ' secondneuron{jj} '       ||']);
        jamfunk(firstneuron{ii},secondneuron{jj},max_hops);
    end
end

function jamfunk(n1,n2,maxhops)
    
m=1; clear numsyn;
disp('one hop paths:');
%find 1-hop paths
for i=1:numrows
    if strcmp(n1,txt(i,1))
        if strcmp(n2,txt(i,2))
            if verb(i)~=0
                p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                  ];
                numsyn(m)=num(i);
                disp(p{m});
                m=m+1;
            end
        end
    end
end
if (m==1) disp('none'); else disp([num2str(m-1) ' 1-hop paths found.']); end;

%%
%find 2-hop paths

if maxhops>1  %2 hops
    disp(' ');
    disp('two hop paths:');
    n=1;
    for i=1:numrows
        if strcmp(n1,txt(i,1))
            for j=1:numrows  
                if strcmp(n2,txt(j,2)) && strcmp(txt(j,1),txt(i,2))
                    if verb(i)~=0 && verb(j)~=0
                        pp{n}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> '...
                            txt{i,2}  ' -' num2str(num(j)) verblist{verb(j)} '-> ' txt{j,2}];
                        numpp1(n)=num(i);
                        numpp2(n)=num(j);
                        disp(pp{n});
                        n=n+1;
                    end
                end
            end
        end
    end
    if (n==1) disp('none');  else disp([num2str(n-1) ' 2-hop paths found.']); end;
end

%%
%%find 3-hop paths

if maxhops>2 %3 hops
    disp(' ');
    disp('three hop paths:');
    
    c2=1;
    for i=1:numrows
        if strcmp(n1,txt(i,1))
            if verb(i)~=0
                ppp_2{c2}=txt(i,2);
                ppp_12{c2}=[num2str(num(i)) verblist{verb(i)}];
                c2=c2+1;
            end
        end
    end
    
    c3=1;
    for i=1:numrows
        if strcmp(n2,txt(i,2))
            if reverb(i)~=0
                ppp_3{c3}=txt(i,1);
                ppp_34{c3}=[num2str(num(i)) verblist{reverb(i)}];
                c3=c3+1;
            end
        end
    end
   c2=c2-1;
   c3=c3-1;
    
    q=1;
    for c=1:c2
        for cc=1:c3
            for i=1:numrows
                if strcmp(ppp_2{c},txt(i,1)) && strcmp(ppp_3{cc},txt(i,2))
                    if verb(i)~=0
                        ppp{q}=[n1 ' -' ppp_12{c} '-> ' txt{i,1} ...
                            ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                            ' -' ppp_34{cc} '-> ' n2];
                        disp(ppp{q});
                        q=q+1;
                    end
                end
            end   
        end
    end
    if (q==1) disp('none'); else disp([num2str(q-1) ' 3-hop paths found.']); end;
end
    
end %jamfunk

end %findpaths