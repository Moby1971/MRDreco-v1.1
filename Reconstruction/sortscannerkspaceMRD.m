function kspace = sortscannerkspaceMRD(app,kspace_in,parameters,ktable)

app.TextMessage('Sorting k-space with scanner table ...');

% dimensions
[dimx,dimy,dimz,nrrep,nrfa,nrte] = size(kspace_in);
kspace = zeros(size(kspace_in));


% navigator yes or no, for RARE echo train correction
if parameters.nav_on == 1
    firsty = parameters.VIEWS_PER_SEGMENT;
else
    firsty = 0;
end


% some parameters
ktable = ktable + 1;
PHshift(1) = 0;

% loop over all dimensions
for te_cnt=1:nrte
    
    for fa_cnt=1:nrfa
        
        for nr_cnt=1:nrrep
            
            for i=1:dimx
                
                for k=1:dimz
                    
                    % determine shift of echoes based on navigator echoes
                    if firsty>0
                        
                        % determine if there is a shift between even and odd echoes
                        for nav=2:firsty
                            
                            % calculate phase difference
                            navecho1 = squeeze(kspace_in(round(dimx/2),1,k,nr_cnt,fa_cnt,te_cnt));
                            navecho2 = squeeze(kspace_in(round(dimx/2),nav,k,nr_cnt,fa_cnt,te_cnt));
                            PHshift(nav) = phase(navecho2) - phase(navecho1);
                            
                        end
                        
                        % sorting including phase correction based on navigator
                        for j = firsty+1:dimy
                            idx = mod(j-firsty+1,firsty)+1;
                            kspace(i,ktable(j)+round(firsty/2),k,nr_cnt,fa_cnt,te_cnt) = kspace_in(i,j,k,nr_cnt,fa_cnt,te_cnt)*exp(-1i*PHshift(idx));
                        end
                        
                    else
                        
                        % sorting without phase correction
                        for j = firsty+1:dimy
                            kspace(i,ktable(j)+round(firsty/2),k,nr_cnt,fa_cnt,te_cnt) = kspace_in(i,j,k,nr_cnt,fa_cnt,te_cnt);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end



end