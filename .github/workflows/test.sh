          # 에러 발생 시 즉시 중단
          set -euo pipefail

          # 초기화
          AWS_REGION=''

          ENV="${{ matrix.envs }}"

          case "$ENV" in
            dev-*)
              echo AWS_ACCESS_KEY_ID="${{ secrets.STG_AWS_ACCESS_KEY_ID }}" >> $GITHUB_ENV
              echo AWS_SECRET_ACCESS_KEY="${{ secrets.STG_AWS_SECRET_ACCESS_KEY }}" >> $GITHUB_ENV
              echo ECR_REPOSITORY='fmm-web-hnd/dev'
              case "$ENV" in
                dev-eu) AWS_REGION='eu-west-1' ;;
                dev-us) AWS_REGION='us-west-2' ;;
                dev-cn) AWS_REGION='ap-southeast-1' ;;
              esac
              ;;

            stg-*)
              echo AWS_ACCESS_KEY_ID="${{ secrets.STG_AWS_ACCESS_KEY_ID }}" >> $GITHUB_ENV
              echo AWS_SECRET_ACCESS_KEY="${{ secrets.STG_AWS_SECRET_ACCESS_KEY }}" >> $GITHUB_ENV
              echo ECR_REPOSITORY='fmm-web-hnd/stg'
              case "$ENV" in
                stg-eu) AWS_REGION='eu-west-1' ;;
                stg-us) AWS_REGION='us-west-2' ;;
              esac
              ;;

            # prd)
            #   echo AWS_ACCESS_KEY_ID="${{ secrets.PRD_AWS_ACCESS_KEY_ID }}" >> $GITHUB_ENV
            #   echo AWS_SECRET_ACCESS_KEY="${{ secrets.PRD_AWS_SECRET_ACCESS_KEY }}" >> $GITHUB_ENV
            #   echo ECR_REPOSITORY="fmm-web-hnd" >> $GITHUB_ENV
            #   AWS_REGION='eu-west-1'
            #   ;;

            # prd-cn)
            #   echo AWS_ACCESS_KEY_ID="${{ secrets.PRD_AWS_ACCESS_KEY_ID }}" >> $GITHUB_ENV
            #   echo AWS_SECRET_ACCESS_KEY="${{ secrets.PRD_AWS_SECRET_ACCESS_KEY }}" >> $GITHUB_ENV
            #   echo ECR_REPOSITORY="fmm-web-hnd" >> $GITHUB_ENV
            #   AWS_REGION='ap-southeast-1'
            #   ;;

            *)
              echo "Unknown matrix.envs: $ENV" >&2
              exit 1
              ;;

          esac

          # 현재 step에서 변수 사용
          export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
          export AWS_REGION=${AWS_REGION}
          export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
          export ECR_REPOSITORY=${ECR_REPOSITORY}

          # 다음 step에서 변수 사용
          echo "ECR_REGISTRY=$ECR_REGISTRY" >> "$GITHUB_ENV"
          echo "AWS_REGION=$AWS_REGION" >> "$GITHUB_ENV"
          echo "ECR_REPOSITORY=$ECR_REPOSITORY" >> "$GITHUB_ENV"

          echo "Resolved: ENV=$ENV, REGION=$AWS_REGION, REGISTRY=$ECR_REGISTRY, REPO=$ECR_REPOSITORY"