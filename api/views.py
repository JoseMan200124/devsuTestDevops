from django.http import JsonResponse
from rest_framework import status, viewsets
from rest_framework.response import Response

from .models import User
from .serializers import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all()

    def list(self, request):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk):
        serializer = self.get_serializer(self.get_object())
        return Response(serializer.data)

    def create(self, request):
        data = request.data

        if self.get_queryset().filter(dni=data.get('dni', '')).exists():
            return Response({'detail': 'User already exists'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data, status=status.HTTP_201_CREATED)


def healthcheck(request):
    return JsonResponse({"status": "ok"}, status=200)
