function [  ] = Saveclustering_full(C, name)
	[k,~]=size(C);
	for i=1:k
		G=C{i,1};
        G=full(G);
		[n1,n2]=size(G);
		fid=fopen(name{i,1},'w');
		for j=1:n1
			for p=1:n2
				if p~=n2
					fprintf(fid,'%f\t', G(j,p));
				else
					fprintf(fid,'%f\n', G(j,p));
				end
			end
		end
		fclose(fid);
	end
end
