using CSV, DataFrames, GLM

function fullfit_metrics(df::DataFrame, covar::Symbol, vars::Vector{Symbol})
    result = zeros(size(vars))

    for (i,v) in enumerate(vars)
        ols = lm(eval(:(@formula($v ~ $covar))), df)

        result[i] = sum(GLM.residuals(ols).^2)
    end

    return result
end

function halffit_metrics(df::DataFrame, covar::Symbol, vars::Vector{Symbol})
    dfsize = size(df, 1)
    result = zeros(size(vars))

    for (i,v) in enumerate(vars)
        print(i);print(" - "); println(v)
        half2_ols = lm(eval(:@formula($v ~ $covar)), df[(dfsize÷2)+1:dfsize, :])

        half1_covar = select(df, covar)[1:dfsize÷2, :]
        half2_vars = df[1:dfsize÷2, v]
        #result[i] = sum(GLM.residuals(half2_ols).^2) + sum((GLM.predict(half2_ols, half1_covar) - half2_vars).^2)
        result[i] = sum(half2_vars - GLM.predict(half2_ols, half1_covar))
    end

    return result
end

function forcelogfit(df::DataFrame, covar::Symbol, vars::Vector{Symbol})
    dfsize = size(df, 1)
    result = zeros(size(vars))

    # This here is hardcoded :c
    ols = glm(eval(:@formula(standard_base_of_truth ~ $covar)), df[1:6, :], Bernoulli(), LogitLink())
    reference_vals = GLM.predict(ols, select(df, :year_value)[4:6, :])

    for (i,v) in enumerate(vars)
        result[i] = sum((reference_vals - df[4:6, vars[i]]).^2)
    end

    return result
end
